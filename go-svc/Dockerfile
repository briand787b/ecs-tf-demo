# BUILD STAGE
FROM golang:1.14 AS builder
WORKDIR /go/app
COPY main.go /go/app/
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -a -o app .

# RUN STAGE
FROM alpine:3.10
RUN mkdir /var/piqlit
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*
WORKDIR /root
COPY --from=builder /go/app/app .
CMD [ "/root/app" ]