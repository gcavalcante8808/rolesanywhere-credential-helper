FROM golang:1.22-bookworm AS builder
ARG VERSION=v1.1.1
WORKDIR /usr/src
RUN git clone --branch ${VERSION} --depth 1 https://github.com/aws/rolesanywhere-credential-helper.git
RUN cd rolesanywhere-credential-helper && \
    make release

FROM debian:12-slim
COPY --from=builder /usr/src/rolesanywhere-credential-helper/build/bin/aws_signing_helper /usr/bin/aws_signing_helper
COPY ./docker-entrypoint.sh /entrypoint
RUN chmod +x /entrypoint
ENTRYPOINT ["/entrypoint"]
