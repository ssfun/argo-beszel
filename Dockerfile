FROM henrygd/beszel AS app

FROM alpine

RUN apk add --no-cache aws-cli zip tzdata

COPY --from=app /beszel /
COPY --from=app /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

EXPOSE 8090

RUN mkdir -p /beszel_data && \
    chmod -R 777 /beszel_data

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
