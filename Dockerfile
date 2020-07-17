FROM nginx:1.19.1-alpine

#
# Copied from https://github.com/nodejs/docker-node/blob/1f26041ed1cdbe7df00004006c4105e6b960fc3e/12/alpine3.12/Dockerfile
#
ENV NODE_VERSION 12.18.2

RUN addgroup -g 1000 node && \
  adduser -u 1000 -G node -G nginx -s /bin/sh -D node && \
  apk add --no-cache libstdc++ && \
  apk add --no-cache --virtual .build-deps curl && \
  ARCH= && \
  alpineArch="$(apk --print-arch)" && \
  case "${alpineArch##*-}" in \
    x86_64) \
      ARCH='x64' \
      CHECKSUM="bd85af8f081a15fc7e957fa129dc7bd5f6926a1104a98ca502982b8ffb8053be" \
      ;; \
    *) \
      ;; \
  esac && \
  if [ -n "${CHECKSUM}" ]; then \
    set -eu; \
    curl -fsSLO --compressed "https://unofficial-builds.nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz"; \
    echo "$CHECKSUM  node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" | sha256sum -c - \
    && tar -xJf "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
    && ln -s /usr/local/bin/node /usr/local/bin/nodejs; \
  fi && \
  rm -f "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" && \
  apk del .build-deps && \
  node --version 

COPY ./nginx.conf /etc/nginx/conf.d/default.conf
WORKDIR /home/node
COPY server.js .

CMD ["sh", "-c", "nginx && su - node -c 'node server.js'"]
