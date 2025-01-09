FROM swift:latest

RUN apt-get update && apt-get install -y libsqlite3-dev

CMD ["swift", "--version"]
