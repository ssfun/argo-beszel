FROM --platform=$BUILDPLATFORM golang:alpine

WORKDIR /app

RUN apk add --no-cache \
    unzip \
    git \
    zip \
    aws-cli \
    ca-certificates

RUN update-ca-certificates

RUN git clone https://github.com/henrygd/beszel.git

# Build
ARG TARGETOS TARGETARCH
RUN CGO_ENABLED=0 GOGC=75 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -ldflags "-w -s" -o /beszel ./cmd/hub

COPY entrypoint.sh /entrypoint.sh

EXPOSE 8090

ENTRYPOINT [ "entrypoint.sh" ]
CMD ["serve", "--http=0.0.0.0:8090"]
