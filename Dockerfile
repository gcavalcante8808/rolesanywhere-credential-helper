FROM python:3.12 AS wrapper-builder
RUN apt-get update && apt-get install patchelf scons -y
WORKDIR /usr/src
COPY wrapper/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY wrapper/wrapper.py .
RUN pyinstaller -F wrapper.py && \
    staticx dist/wrapper aws-credentials-wrapper && \
    chmod 555 aws-credentials-wrapper

FROM golang:1.22-alpine3.19 AS alpine-builder
ARG VERSION=v1.1.1
WORKDIR /usr/src
RUN apk add --no-cache git make gcc musl-dev
RUN git clone --branch ${VERSION} --depth 1 https://github.com/aws/rolesanywhere-credential-helper.git
RUN cd rolesanywhere-credential-helper && \
    make release

FROM alpine:3.19 AS alpine-target
RUN apk add --no-cache bash
COPY --from=alpine-builder /usr/src/rolesanywhere-credential-helper/build/bin/aws_signing_helper /usr/bin/aws_signing_helper
COPY --from=wrapper-builder /usr/src/aws-credentials-wrapper /usr/bin/aws-credentials-wrapper
COPY ./docker-entrypoint.sh /entrypoint
RUN chmod +x /entrypoint
ENTRYPOINT ["/entrypoint"]

FROM golang:1.22-bookworm AS gnu-builder
ARG VERSION=v1.1.1
WORKDIR /usr/src
RUN git clone --branch ${VERSION} --depth 1 https://github.com/aws/rolesanywhere-credential-helper.git
RUN cd rolesanywhere-credential-helper && \
    make release

FROM debian:12-slim AS debian-target
COPY --from=gnu-builder /usr/src/rolesanywhere-credential-helper/build/bin/aws_signing_helper /usr/bin/aws_signing_helper
COPY --from=wrapper-builder /usr/src/aws-credentials-wrapper /usr/bin/aws-credentials-wrapper

COPY ./docker-entrypoint.sh /entrypoint
RUN chmod +x /entrypoint
ENTRYPOINT ["/entrypoint"]
