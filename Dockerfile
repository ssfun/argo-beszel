FROM henrygd/beszel AS app

FROM alpine:latest

RUN apk add --no-cache aws-cli tar gzip tzdata

RUN cp /usr/share/zoneinfo/Your/Timezone /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

COPY --from=app /beszel /
COPY --from=app /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

EXPOSE 8090

RUN mkdir -p /beszel_data && \
    chmod -R 777 /beszel_data

COPY backup.sh /backup.sh
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /backup.sh && chmod +x /entrypoint.sh
RUN echo "*/5 * * * * /backup.sh >> /var/log/backup.log 2>&1" > /var/spool/cron/crontabs/root

ENTRYPOINT [ "/entrypoint.sh" ]

CMD ["serve", "--http=0.0.0.0:8090"]
