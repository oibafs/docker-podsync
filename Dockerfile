# Clone mxpv/podsync for latest commit
FROM alpine/git:latest AS cloner
LABEL stage=clone
WORKDIR /workspace
RUN git clone https://github.com/mxpv/podsync.git

# Build from latest commit
FROM golang:alpine AS builder
LABEL stage=builder
WORKDIR /workspace
COPY --from=cloner /workspace/podsync/ .
RUN go build -o /bin/podsync ./cmd/podsync

FROM alpine:latest
WORKDIR /app/
RUN apk --no-cache upgrade && \
  apk --no-cache add ca-certificates ffmpeg tzdata python3 && \
  wget -q -O /usr/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp && \
  chmod +x /usr/bin/yt-dlp && \
  ln -s /usr/bin/yt-dlp /usr/bin/youtube-dl
RUN apk add --no-cache gawk
COPY --from=builder /bin/podsync .
COPY copy.sh .
RUN chmod +x copy.sh

# Run podsync in headless mode
# CMD ["/app/podsync", "--headless"]

# Run script to prepare environment variables and execute Podsync
CMD ["./copy.sh"]