Small utility to ingest nginx access log files into a sqlite database and then generate basic reports.

```
OVERVIEW: A utility for ingesting nginx logs and generating reports

USAGE: log-parser <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  ingest                  Ingest and parse access logs
  report                  Generate usage reports

  See 'log-parser help <subcommand>' for detailed help.
```

**Ingest Logs:**
```
OVERVIEW: Ingest and parse access logs

USAGE: log-parser ingest [--database <database>] [--log-file <log-file>] [--path-filter <path-filter>]

OPTIONS:
  -d, --database <database>
                          Data directory for storing the SQLite db (default:
                          /Users/adm/.local/share/logparser)
  --log-file <log-file>   Location of the nginx log file to ingest (default:
                          /var/log/nginx/access.log)
  --path-filter <path-filter>
                          Only record log entries where the path contains this
                          string
  -h, --help              Show help information.

```

**Generate Reports:**
```
OVERVIEW: Generate usage reports

USAGE: log-parser report [--limit <limit>] [--database <database>] [--path-counts] [--requests-by-ip] [--data-per-path] [--data-per-ip]

OPTIONS:
  --limit <limit>         Limit the number of reported results
  -d, --database <database>
                          Data directory for storing the SQLite db (default:
                          /Users/adm/.local/share/logparser)
  --path-counts/--requests-by-ip/--data-per-path/--data-per-ip
                          Select one or more reports to generate
  -h, --help              Show help information.
```


**Build for Linux:**

```
docker run -v "$PWD:/code" -w /code --platform linux/amd64 -e QEMU_CPU=max acoffman/swift-builder:latest swift build -c release --static-swift-stdlib
```

(Can normally just use official `swift:latest` but it lacks the sqlite headers needed.
