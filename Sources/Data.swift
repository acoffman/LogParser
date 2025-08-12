import ArgumentParser
import Foundation

struct Request {
  var ip: String
  var path: String
  var timestamp: Date
  var size: Int
  var userAgent: String
}

enum ReportType: EnumerableFlag, Hashable {
  case pathCounts
  case requestsByIp
  case dataPerPath
  case dataPerIp
}

enum GroupByPeriod: String, CaseIterable, ExpressibleByArgument {
  case day = "day"
  case week = "week"
  case month = "month"
}
