FROM alpine:3.20

LABEL org.opencontainers.image.source="https://github.com/odit-services/docker-backup-files"
LABEL org.opencontainers.image.description="Docker image to periodically backup files to S3 (tested with AWS S3, Minio and Wasabi)."
LABEL org.opencontainers.image.licenses=MIT

RUN ARCH=`uname -m` && \
    if [ "$ARCH" == "x86_64" ]; then \
        export ARCH="amd64"; \
    else \
        export ARCH="arm64"; \
    fi; \
    apk add --no-cache tar=1.35-r2 gzip=1.13-r0 bash=5.2.26-r0 curl=8.9.1-r2 jq=1.7.1-r0 && \
    curl "https://dl.min.io/client/mc/release/linux-${ARCH}/mc" -o /bin/mc && \
    chmod +x /bin/mc
COPY --chown=backup:backup *.sh /
RUN chmod +x /*.sh
# USER backup
ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]