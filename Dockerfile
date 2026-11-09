FROM alpine:3.24

LABEL org.opencontainers.image.source="https://github.com/odit-services/docker-backup-files"
LABEL org.opencontainers.image.description="Docker image to periodically backup files to S3 (tested with AWS S3, Minio and Wasabi)."
LABEL org.opencontainers.image.licenses=MIT

RUN apk add --no-cache tar=1.35-r5 gzip=1.15-r0 bash=5.3.9-r1 jq=1.8.2-r0 minio-client=0.20250813.083541-r9 && \
    ln -s /usr/bin/mcli /usr/bin/mc
COPY *.sh /
RUN chmod +x /*.sh
# USER backup
ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]