import ArgumentParser
import Foundation

struct Request {
  var ip: String
  var path: String
  var timestamp: Date
  var size: Int
  var userAgent: String
}

enum ReportType: EnumerableFlag {
  case pathCounts
  case requestsByIp
  case dataPerPath
  case dataPerIp
}
