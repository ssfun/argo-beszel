FROM henrygd/beszel AS app

FROM alpine

RUN apk add --no-cache aws-cli tar gzip tzdata

COPY --from=cloudflare/cloudflared:latest /usr/local/bin/cloudflared /usr/local/bin/cloudflared
COPY --from=app /beszel /
COPY --from=app /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

EXPOSE 8090

COPY backup.sh /backup.sh
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["serve", "--http=0.0.0.0:8090"]
