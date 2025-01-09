import Foundation
import SQLite

struct Database {
  var db: Connection

  let requests = Table("requests")
  let id = SQLite.Expression<Int64>("id")
  let ip = SQLite.Expression<String>("ip")
  let path = SQLite.Expression<String>("path")
  let timestamp = SQLite.Expression<Date>("timestamp")
  let size = SQLite.Expression<Int64>("size")
  let userAgent = SQLite.Expression<String>("userAgent")

  func setup() throws {
    if db.userVersion == 0 {
      try db.run(
        requests.create(ifNotExists: true) { t in
          t.column(id, primaryKey: .autoincrement)
          t.column(ip)
          t.column(path)
          t.column(timestamp)
          t.column(size)
          t.column(userAgent)
        })

      try db.run(requests.createIndex(ip))
      try db.run(requests.createIndex(path))
      try db.run(requests.createIndex(timestamp))
      try db.run(requests.createIndex(size))
      try db.run(requests.createIndex(userAgent))

      db.userVersion = 1
    }
  }

  func insertRequest(_ request: Request) throws {
    try db.run(
      requests.insert(
        ip <- request.ip,
        path <- request.path,
        timestamp <- request.timestamp,
        size <- request.size,
        userAgent <- request.userAgent
      )
    )
  }
}
