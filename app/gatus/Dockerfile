# stage 1: build binary

FROM golang:alpine AS builder
RUN apk --update add ca-certificates
WORKDIR /app
COPY . ./
# -s = symbol table, -w = DWARF debugging info
RUN go build -v -trimpath -ldflags="-s -w" -o gatus . 

# stage 2: run the binary

FROM alpine:3.23 
RUN addgroup -g 10001 -S gatus \
&& adduser -u 10001 -S gatus -g gatus  

WORKDIR /app

COPY --from=builder /app/gatus /app/gatus
COPY --chown=gatus:gatus entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh \
&& chown -R gatus:gatus /app \
&& chmod 500 /app/gatus

USER gatus
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]