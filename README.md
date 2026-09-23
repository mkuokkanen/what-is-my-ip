# What is my IP

Simple web server app written in swift that displays callers ip as seen by the server app.


## Local development

### Run locally

Build and start application

    swift run App serve --log debug

Then try making request

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
