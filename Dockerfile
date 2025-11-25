# Dockerfile
ARG IMMICH_VERSION=release
FROM ghcr.io/immich-app/immich-server:${IMMICH_VERSION}

RUN apt-get update && \
    apt-get install -y gocryptfs fuse && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
