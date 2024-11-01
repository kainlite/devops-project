### Build stage
FROM golang:1.23 AS build

WORKDIR /app

COPY go.mod ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o /app/app

RUN groupadd --gid 1000 appgroup && \
    useradd -u 1000 appuser && \
    chown -R 1000:1000 /app

### Test stage
FROM build AS test
RUN go test -v ./...

### Final image from scratch
FROM scratch

WORKDIR /app

COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /app/app /app/app

USER appuser

EXPOSE 8080

CMD ["/app/app"]
