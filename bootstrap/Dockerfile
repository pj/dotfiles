FROM alpine AS test-alpine
COPY ./bootstrap.sh ./bootstrap.sh
RUN ./bootstrap.sh

FROM ubuntu AS test-ubuntu
COPY ./bootstrap.sh ./bootstrap.sh
RUN ./bootstrap.sh

FROM chainguard/wolfi-base AS test-wolfi
COPY ./bootstrap.sh ./bootstrap.sh
RUN ./bootstrap.sh