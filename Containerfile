# Build stage
FROM golang:alpine AS builder

WORKDIR /src
RUN apk add --no-cache git \
	&& git clone https://github.com/Random-typ/hydroxide.git .
RUN CGO_ENABLED=0 go build -o /bin/hydroxide ./cmd/hydroxide

# Runtime stage
FROM alpine:latest

RUN apk add --no-cache ca-certificates bash

COPY --from=builder /bin/hydroxide /usr/local/bin/hydroxide
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose IMAP, SMTP, CardDAV ports
EXPOSE 1143 1025 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
