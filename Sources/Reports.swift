import Foundation
import SQLite

protocol Report {
  var db: Database { get }
  func countCol() -> SQLite.Expression<Int>
  func groupCol() -> SQLite.Expression<String>
  func formatter(_: Int) -> String
  init(db: Database)
}

extension Report {
  init(db: Database) {
    self.init(db: db)
  }

  func formatter(_ val: Int) -> String { String(val) }
  func run(
    limit: Int? = nil, startDate: Date? = nil, endDate: Date? = nil,
    rowHandler: (String, Int) -> Void
  ) throws {

    var query = self.db.requests.group(groupCol())
      .select(groupCol(), countCol())
      .limit(limit)
      .order(countCol().desc)

    if startDate != nil {
      query = query.where(self.db.timestamp >= startDate!)
    }

    if endDate != nil {
      query = query.where(self.db.timestamp <= endDate!)
    }

    for row in try self.db.conn.prepare(query) {
      rowHandler(row[groupCol()], row[countCol()])
    }
  }
}

struct PathCountsReport: Report {
  var db: Database

  func countCol() -> SQLite.Expression<Int> { self.db.id.count }
  func groupCol() -> SQLite.Expression<String> { self.db.path }
}

struct RequestsByIpReport: Report {
  var db: Database

  func countCol() -> SQLite.Expression<Int> { self.db.id.count }
  func groupCol() -> SQLite.Expression<String> { self.db.ip }
}

struct DataPerPathReport: Report {
  var db: Database

  func formatter(_ val: Int) -> String { Formatter.formatByteString(value: val) }
  func countCol() -> SQLite.Expression<Int> { self.db.size.sum ?? 0 }
  func groupCol() -> SQLite.Expression<String> { self.db.path }
}

struct DataPerIpReport: Report {
  var db: Database

  func formatter(_ val: Int) -> String { Formatter.formatByteString(value: val) }
  func countCol() -> SQLite.Expression<Int> { self.db.size.sum ?? 0 }
  func groupCol() -> SQLite.Expression<String> { self.db.ip }
}
