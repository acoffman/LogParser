import ArgumentParser
import Foundation
import SQLite

extension LogParser {
  struct Ingest: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Ingest and parse access logs")

    @OptionGroup var databaseOptions: DatabaseOptions

    @Option(help: "Location of the nginx log file to ingest")
    var logFile = "/var/log/nginx/access.log"

    @Option(help: "Only record log entries where the path contains this string")
    var pathFilter: String?

    public func run() async throws {

      do {
        let fileManager = FileManager()
        try fileManager.createDirectory(
          atPath: self.databaseOptions.dbLocation, withIntermediateDirectories: true)

        let db = try Connection(
          self.databaseOptions.dbLocation.appending(self.databaseOptions.databaseName))
        let database = Database(db: db)
        let parser = Parser()

        try database.setup()

        let fileUrl = URL(filePath: self.logFile)
        let fileHandle = try FileHandle(forReadingFrom: fileUrl)

        defer {
          fileHandle.closeFile()
        }

        if let data = try? fileHandle.readToEnd(),
          let contents = String(data: data, encoding: .utf8)
        {
          let lines = contents.components(separatedBy: .newlines)
          for line in lines {
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
        }
      } catch {
        print(error)
      }
    }
  }
}
