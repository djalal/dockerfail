# BUILD
FROM golang:alpine as builder

WORKDIR /go
COPY dispatcher.go .
RUN go build dispatcher.go

# RUN
FROM alpine:3

RUN apk add --no-cache --update curl=7.88.1-r1

EXPOSE 80
CMD ["/dispatcher"]

COPY --from=builder /go/dispatcher /
COPY static /static/

HEALTHCHECK --interval=60s --timeout=10s --start-period=10s  \
    CMD curl --fail http://localhost/index.html
