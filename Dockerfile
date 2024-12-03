FROM henrygd/beszel AS app

FROM alpine

RUN apk add --no-cache aws-cli zip tzdata

COPY --from=app /beszel /beszel
COPY --from=app /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

RUN mkdir -p /beszel/beszel_data

EXPOSE 8090

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
