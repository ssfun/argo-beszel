# 使用 alpine 作为中间层来安装 aws-cli 和 zip
FROM alpine:latest AS tools

# 安装 aws-cli 和 zip
RUN apk add --no-cache \
    aws-cli \
    zip

# 使用 henrygd/beszel 作为基础镜像
FROM henrygd/beszel

# 从 tools 中间层复制 aws-cli 和 zip
COPY --from=tools /usr/bin/aws /usr/bin/aws
COPY --from=tools /usr/bin/zip /usr/bin/zip
COPY --from=tools /usr/bin/unzip /usr/bin/unzip

# 将 entrypoint.sh 复制到镜像中
COPY entrypoint.sh /entrypoint.sh

# 暴露端口
EXPOSE 8090

# 设置 entrypoint.sh 为容器的入口点
ENTRYPOINT ["/entrypoint.sh"]
