# 使用 golang:alpine 作为构建阶段的基础镜像，并指定平台
FROM --platform=$BUILDPLATFORM golang:alpine AS builder

# 设置工作目录
WORKDIR /app

# 克隆项目代码
RUN apk add --no-cache git
RUN git clone https://github.com/henrygd/beszel.git /

COPY --from=builder /beszel /app

# 下载 Go 模块
RUN go mod download

# 安装必要的工具
RUN apk add --no-cache \
    unzip \
    ca-certificates

RUN update-ca-certificates

# 构建
ARG TARGETOS TARGETARCH
RUN CGO_ENABLED=0 GOGC=75 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -ldflags "-w -s" -o /beszel ./cmd/hub

# -------------------------
# 使用 alpine 作为最终镜像的基础镜像
FROM alpine

# 复制构建好的二进制文件
COPY --from=builder /beszel /

# 复制 CA 证书
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

RUN apk add --no-cache \
    zip \
    aws-cli

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 8090

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["serve", "--http=0.0.0.0:8090"]
