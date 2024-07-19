FROM python:3.12 AS wrapper-builder
RUN apt-get update && apt-get install patchelf scons -y
WORKDIR /usr/src
COPY wrapper/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY wrapper/wrapper.py .
RUN pyinstaller -F wrapper.py && \
    staticx dist/wrapper aws-credentials-wrapper

FROM golang:1.22-bookworm AS builder
ARG VERSION=v1.1.1
WORKDIR /usr/src
RUN git clone --branch ${VERSION} --depth 1 https://github.com/aws/rolesanywhere-credential-helper.git
RUN cd rolesanywhere-credential-helper && \
    make release

FROM debian:12-slim
COPY --from=builder /usr/src/rolesanywhere-credential-helper/build/bin/aws_signing_helper /usr/bin/aws_signing_helper
COPY --from=wrapper-builder /usr/src/aws-credentials-wrapper /usr/bin/aws-credentials-wrapper
COPY ./docker-entrypoint.sh /entrypoint
RUN chmod +x /entrypoint
ENTRYPOINT ["/entrypoint"]
