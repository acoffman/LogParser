import Foundation
import SQLite

protocol Report {
  var db: Database { get }
  func countCol() -> SQLite.Expression<Int>
  func groupCol() -> SQLite.Expression<String>
  func formatter(_: Int) -> String
  func getCountExpression() -> String
  init(db: Database)
}

extension Report {
  init(db: Database) {
    self.init(db: db)
  }

  func formatter(_ val: Int) -> String { String(val) }
  func run(
    limit: Int? = nil, startDate: Date? = nil, endDate: Date? = nil, groupBy: GroupByPeriod? = nil,
    rowHandler: (String, Int) -> Void
  ) throws {

    if let groupBy = groupBy {
      // For time-based grouping, use raw SQL for better control
      try runTimeGroupedQuery(
        limit: limit, startDate: startDate, endDate: endDate, groupBy: groupBy, 
        rowHandler: rowHandler
      )
    } else {
      // Original grouping behavior
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
  
  private func runTimeGroupedQuery(
    limit: Int?, startDate: Date?, endDate: Date?, groupBy: GroupByPeriod,
    rowHandler: (String, Int) -> Void
  ) throws {
    let timeGroupFunc = getTimeGroupFunction(groupBy)
    let countExpression = self.getCountExpression()  // Use the report's own method
    
    var sql = "SELECT \(timeGroupFunc) as time_group, \(countExpression) as count_val FROM requests"
    var whereConditions: [String] = []
    
    if startDate != nil {
      whereConditions.append("timestamp >= ?")
    }
    if endDate != nil {
      whereConditions.append("timestamp <= ?")
    }
    
    if !whereConditions.isEmpty {
      sql += " WHERE " + whereConditions.joined(separator: " AND ")
    }
    
    sql += " GROUP BY \(timeGroupFunc) ORDER BY time_group ASC"
    
    if let limit = limit {
      sql += " LIMIT \(limit)"
    }
    
    let statement = try self.db.conn.prepare(sql)
    
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    
    var bindValues: [String] = []
    if let startDate = startDate {
      bindValues.append(dateFormatter.string(from: startDate))
    }
    if let endDate = endDate {
      bindValues.append(dateFormatter.string(from: endDate))
    }
    
    // Bind all values at once
    if !bindValues.isEmpty {
      _ = statement.bind(bindValues)
    }
    
    for row in statement {
      let timeGroup = row[0] as! String
      let count = row[1] as! Int64
      rowHandler(timeGroup, Int(count))
    }
  }
  
  private func getTimeGroupFunction(_ groupBy: GroupByPeriod) -> String {
    switch groupBy {
    case .day:
      return "DATE(timestamp)"
    case .week:
      return "DATE(timestamp, 'weekday 0', '-6 days')"
    case .month:
      return "DATE(timestamp, 'start of month')"
    }
  }
}

struct PathCountsReport: Report {
  var db: Database

  func countCol() -> SQLite.Expression<Int> { self.db.id.count }
  func groupCol() -> SQLite.Expression<String> { self.db.path }
  func getCountExpression() -> String { "COUNT(*)" }
}

struct RequestsByIpReport: Report {
  var db: Database

  func countCol() -> SQLite.Expression<Int> { self.db.id.count }
  func groupCol() -> SQLite.Expression<String> { self.db.ip }
  func getCountExpression() -> String { "COUNT(*)" }
}

struct DataPerPathReport: Report {
  var db: Database

  func formatter(_ val: Int) -> String { Formatter.formatByteString(value: val) }
  func countCol() -> SQLite.Expression<Int> { self.db.size.sum ?? 0 }
  func groupCol() -> SQLite.Expression<String> { self.db.path }
  func getCountExpression() -> String { "SUM(size)" }
}

struct DataPerIpReport: Report {
  var db: Database

  func formatter(_ val: Int) -> String { Formatter.formatByteString(value: val) }
  func countCol() -> SQLite.Expression<Int> { self.db.size.sum ?? 0 }
  func groupCol() -> SQLite.Expression<String> { self.db.ip }
  func getCountExpression() -> String { "SUM(size)" }
}
