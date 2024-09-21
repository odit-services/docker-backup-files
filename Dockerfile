FROM alpine:3.20

LABEL org.opencontainers.image.source="https://github.com/odit-services/docker-backup-files"
LABEL org.opencontainers.image.description="Docker image to periodically backup files to S3 (tested with AWS S3, Minio and Wasabi)."
LABEL org.opencontainers.image.licenses=MIT

RUN apk add --no-cache minio-client=0.20240524.090849-r2 tar=1.35-r2 gzip=1.13-r0
COPY --chown=backup:backup *.sh /
RUN chmod +x /*.sh
USER backup
ENTRYPOINT [ "/entrypoint.sh" ]