import Foundation

enum ParseError: Error {
  case parseError(String)
}

struct Parser {
  let logPattern =
    /(?<ip>\d{1,3}(?:\.\d{1,3}){3}) - - \[(?<timestamp>[^\]]+)\] "(?<method>\S+) (?<path>\S+) \S+" (?<status>\d{3}) (?<size>\d+) "(?<referrer>[^\"]*)" "(?<userAgent>[^\"]*)"/

  let dateFormatter = DateFormatter()

  init() {
    self.dateFormatter.dateFormat = "dd/MMM/yyyy:HH:mm:ss Z"
    self.dateFormatter.locale = Locale.current
    self.dateFormatter.timeZone = TimeZone.gmt
  }

  func parseLine(_ line: String) throws -> Request {
    if let result = try logPattern.wholeMatch(in: line) {
      if let date = dateFormatter.date(from: String(result.timestamp)) {
        return Request(
          ip: String(result.ip),
          path: String(result.path),
          timestamp: date,
          size: Int(String(result.size))!,
          userAgent: String(result.userAgent)
        )
      }
    }
    throw ParseError.parseError("Failed to parse line \(line)")
  }
}
