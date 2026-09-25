# What is my IP

Simple web server app written in swift that displays callers ip as seen by the server app.

## Configuration

Application is configured with environment variables.

### IP_SOURCE

Chooses where the client IP is read from

- `remote-address` (default): address of the connecting client, for running without a proxy
- `x-forwarded-for`: `X-Forwarded-For` header, as set by Traefik
- `forwarded`: `Forwarded` header (RFC 7239). Not yet implemented, requests return `501 Not Implemented`

Behind a proxy, set it to the header the proxy sets, otherwise every client gets the proxy's address.
Any other value stops the application at startup.

### LOG_HEADERS

`true` logs all request headers, for debugging only. Default is `false`.
Headers are logged at `debug` level, so `LOG_LEVEL` must also be `debug` or lower.

### LOG_LEVEL

Log level: `trace`, `debug`, `info`, `notice`, `warning`, `error` or `critical`.
The `--log` command line option overrides it.
Default is `notice` with `--env production` and `info` otherwise.
Requests are logged at `info` level.

## Local development

### Run locally

Build and start application

    swift run App serve --log debug

Then try making request

    curl localhost:8080

To read the IP from the `X-Forwarded-For` header, as in production behind Traefik

    IP_SOURCE=x-forwarded-for swift run App serve --log debug
    curl --header "X-Forwarded-For: 1.2.3.4" localhost:8080

To also log all request headers (debug level), set `LOG_HEADERS=true`

    LOG_HEADERS=true swift run App serve --log debug

### Run with Docker Compose

Build the application into a container and run it. Debug and header logging are enabled.

    docker compose build
    docker compose up

Then try making request

    curl --header "X-Forwarded-For: 1.2.3.4" localhost:8080

### Run unit tests

    swift test

### Dependencies

Update dependencies

    swift package update

Show dependency tree

    swift package show-dependencies

### Format source code

    swift format . --recursive --in-place
