import ArgumentParser
import Foundation
import SQLite

@main
struct LogParser: AsyncParsableCommand {

  @Option(
    name: [.short, .customLong("database")],
    help: "Data directory for storing the SQLite db")
  var dbLocation: String = FileManager.default.homeDirectoryForCurrentUser.appending(
    path: ".local/share/logparser"
  ).path

  @Option(help: "Location of the nginx log file to ingest")
  var logFile = "/var/log/nginx/access.log"

  @Option(help: "Only record log entries where the path contains this string")
  var pathFilter: String?

  public func run() async throws {
    let databaseName = "/db.sqlite3"

    do {
      let fileManager = FileManager()
      try fileManager.createDirectory(atPath: self.dbLocation, withIntermediateDirectories: true)

      let db = try Connection(self.dbLocation.appending(databaseName))
      let database = Database(db: db)
      let parser = Parser()

      try database.setup()

      let fileUrl = URL(filePath: self.logFile)
      let fileHandle = try FileHandle(forReadingFrom: fileUrl)

      defer {
        fileHandle.closeFile()
      }

      for try await line in fileHandle.bytes.lines {
        //for speed, don't parse the line at all unless it contains our target string
        if let filter = self.pathFilter {
          if !line.contains(filter) { continue }
        }

        if let request = try? parser.parseLine(line) {
          //make sure the filter string appears specifically in the request path
          if let filter = self.pathFilter {
            if !request.path.contains(filter) { continue }
          }
          try database.insertRequest(request)
        } else {
          print("Failed to parse: \(line)")
        }
      }
    } catch {
      print(error)
    }

  }
}
