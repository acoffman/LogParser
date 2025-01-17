import ArgumentParser
import Foundation
import SQLite

extension LogParser {
  struct GenerateReport: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "report", abstract: "Generate usage reports")

    @Option(help: "Limit the number of reported results")
    var limit: Int?
    @Option(help: "Include only requests on or after this date", transform: DateParser.parseDate)
    var startDate: Date?
    @Option(help: "Include only requests on or before this date", transform: DateParser.parseDate)
    var endDate: Date?

    @OptionGroup var databaseOptions: DatabaseOptions

    @Flag(help: "Select one or more reports to generate") var reports: [ReportType] = []

    public func run() async throws {
      let availableReports: [ReportType: Report.Type] = [
        .pathCounts: PathCountsReport.self,
        .requestsByIp: RequestsByIpReport.self,
        .dataPerPath: DataPerPathReport.self,
        .dataPerIp: DataPerIpReport.self,
      ]

      if self.reports.isEmpty {
        print("Please select one or more reports to generate.")
        return
      }

      do {
        let conn = try Connection(
          self.databaseOptions.dbLocation.appending(self.databaseOptions.databaseName))
        let database = Database(conn: conn)

        for selectedReport in self.reports {
          if let reportType = availableReports[selectedReport] {
            let report = reportType.init(db: database)
            try report.run(limit: self.limit, startDate: self.startDate, endDate: self.endDate) {
              (val, count) in
              print("\(val)\t\(report.formatter(count))")
            }
          }
          print("\n")
        }
      } catch {
        print(error)
      }
    }
  }
}
