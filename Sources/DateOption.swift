import ArgumentParser
import Foundation

struct DateParser {
  static let formatter = DateFormatter()
  static func parseDate(_ arg: String) throws -> Date {
    formatter.dateStyle = .short
    guard let date = formatter.date(from: arg) else {
      throw ParseError.parseError("Invalid date format \(arg)")
    }
    return date
  }
}
