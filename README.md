Build for Linux:

```
docker run -v "$PWD:/code" -w /code --platform linux/amd64 -e QEMU_CPU=max acoffman/swift-builder:latest swift build -c release --static-swift-stdlib
```

(Can normally just use official `swift:latest` but it lacks the sqlite headers needed.
