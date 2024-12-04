FROM henrygd/beszel AS app

FROM alpine:latest

RUN apk add --no-cache aws-cli zip

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata

COPY --from=app /beszel /
COPY --from=app /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

EXPOSE 8090

RUN mkdir -p /beszel_data && \
    chmod -R 777 /beszel_data

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

CMD ["serve", "--http=0.0.0.0:8090"]
