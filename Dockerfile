FROM golang:1.22-alpine3.19 AS builder
ARG VERSION=v1.1.1
WORKDIR /usr/src
RUN apk add --no-cache git make gcc musl-dev
RUN git clone --branch ${VERSION} --depth 1 https://github.com/aws/rolesanywhere-credential-helper.git
RUN cd rolesanywhere-credential-helper && \
    make release

FROM alpine:3.19
RUN apk add --no-cache bash
COPY --from=builder /usr/src/rolesanywhere-credential-helper/build/bin/aws_signing_helper /usr/bin/aws_signing_helper
COPY ./docker-entrypoint.sh /entrypoint
RUN chmod +x /entrypoint
ENTRYPOINT ["/entrypoint"]
