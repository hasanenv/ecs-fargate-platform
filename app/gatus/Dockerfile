# stage 1: build binary 
FROM golang:alpine AS builder
RUN apk --update add ca-certificates
WORKDIR /app
COPY . ./
RUN go build -v -trimpath -ldflags="-s -w" -o gatus .

# stage 2: run binary
FROM dhi.io/alpine-base:3.23-alpine3.23-dev

WORKDIR /app

COPY --from=builder /app/gatus /app/gatus
COPY --from=builder /app/entrypoint.sh /entrypoint.sh

RUN chown -R nonroot:nonroot /app \
    && chmod +x /entrypoint.sh \
    && chmod 500 /app/gatus

USER nonroot
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]