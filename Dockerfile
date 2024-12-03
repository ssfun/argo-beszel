# 使用 alpine 作为中间层来安装 aws-cli 和 zip
FROM alpine:latest AS tools

# 安装 aws-cli 和 zip
RUN apk add --no-cache \
    aws-cli \
    zip

# 将 entrypoint.sh 复制到镜像中并确保其具有可执行权限
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 使用 henrygd/beszel 作为基础镜像
FROM henrygd/beszel

# 从 tools 中间层复制 aws-cli 和 zip entrypoint.sh
COPY --from=tools /usr/bin/aws /usr/bin/aws
COPY --from=tools /usr/bin/zip /usr/bin/zip
COPY --from=tools /usr/bin/unzip /usr/bin/unzip
COPY --from=tools /entrypoint.sh /entrypoint.sh

# 设置 entrypoint.sh 为容器的入口点
ENTRYPOINT ["/entrypoint.sh"]

# 暴露端口
EXPOSE 8090

# 默认的 CMD 命令
CMD ["serve", "--http=0.0.0.0:8090"]
