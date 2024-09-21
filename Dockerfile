FROM alpine:3.20

RUN apk add --no-cache minio-client=0.20240524.090849-r2 tar=1.35-r2 gzip=1.13-r0
COPY --chown=backup:backup *.sh /
RUN chmod +x /*.sh
USER backup
ENTRYPOINT [ "/entrypoint.sh" ]