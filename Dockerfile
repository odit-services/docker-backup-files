FROM alpine:3.24

LABEL org.opencontainers.image.source="https://github.com/odit-services/docker-backup-files"
LABEL org.opencontainers.image.description="Docker image to periodically backup files to S3 (tested with AWS S3, Minio and Wasabi)."
LABEL org.opencontainers.image.licenses=MIT

RUN ARCH=`uname -m` && \
    if [ "$ARCH" == "x86_64" ]; then \
        export ARCH="amd64"; \
    else \
        export ARCH="arm64"; \
    fi; \
    apk add --no-cache tar=1.35-r5 gzip=1.15-r0 bash=5.3.9-r1 curl=8.23.0-r0 jq=1.8.2-r0 && \
    curl "https://dl.min.io/client/mc/release/linux-${ARCH}/mc" -o /bin/mc && \
    chmod +x /bin/mc
COPY --chown=backup:backup *.sh /
RUN chmod +x /*.sh
# USER backup
ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]