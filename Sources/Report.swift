import ArgumentParser
import Foundation
import SQLite

extension LogParser {
  struct Report: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Generate usage reports")

    @Option(help: "Limit the number of reported results")
    var limit: Int?
    @Option(help: "Include only requests on or after this date", transform: DateParser.parseDate)
    var startDate: Date?
    @Option(help: "Include only requests on or before this date", transform: DateParser.parseDate)
    var endDate: Date?

    @OptionGroup var databaseOptions: DatabaseOptions

    @Flag(help: "Select one or more reports to generate") var reports: [ReportType] = []

    public func run() async throws {
      if self.reports.isEmpty {
        print("Please select one or more reports to generate.")
        return
      }

      do {
        let db = try Connection(
          self.databaseOptions.dbLocation.appending(self.databaseOptions.databaseName))
        let database = Database(db: db)

        for report in self.reports {
          try database.runReport(
            report, limit: self.limit, startDate: self.startDate, endDate: self.endDate
          ) { (val, count) in
            print("\(val)\t\(count)")
          }
          print("\n")
        }
      } catch {
        print(error)
      }
    }
  }
}
