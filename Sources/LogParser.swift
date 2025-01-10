import ArgumentParser
import Foundation
import SQLite

@main
struct LogParser: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "A utility for ingesting nginx logs and generating reports",
    subcommands: [Ingest.self, Report.self])

  struct DatabaseOptions: ParsableArguments {
    var databaseName = "/db.sqlite3"

    @Option(
      name: [.short, .customLong("database")],
      help: "Data directory for storing the SQLite db")
    var dbLocation: String = FileManager.default.homeDirectoryForCurrentUser.appending(
      path: ".local/share/logparser"
    ).path
  }
}
