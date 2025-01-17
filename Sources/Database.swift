import Foundation
import SQLite

struct Database {
  var conn: Connection

  let requests = Table("requests")
  let id = SQLite.Expression<Int>("id")
  let ip = SQLite.Expression<String>("ip")
  let path = SQLite.Expression<String>("path")
  let timestamp = SQLite.Expression<Date>("timestamp")
  let size = SQLite.Expression<Int>("size")
  let userAgent = SQLite.Expression<String>("userAgent")

  func setup() throws {
    if conn.userVersion == 0 {
      try conn.run(
        requests.create(ifNotExists: true) { t in
          t.column(id, primaryKey: .autoincrement)
          t.column(ip)
          t.column(path)
          t.column(timestamp)
          t.column(size)
          t.column(userAgent)
        })

      try conn.run(requests.createIndex(ip))
      try conn.run(requests.createIndex(path))
      try conn.run(requests.createIndex(timestamp))
      try conn.run(requests.createIndex(size))
      try conn.run(requests.createIndex(userAgent))

      conn.userVersion = 1
    }
  }

  func insertRequest(_ request: Request) throws {
    try conn.run(
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
