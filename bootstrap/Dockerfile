FROM alpine AS test-alpine
RUN curl -L0 https://github.com/pj/dotfiles/releases/download/latest/bootstrap-linux-amd64 -O
RUN bootstrap-linux-amd64

# FROM ubuntu AS test-ubuntu
# COPY ./bootstrap.sh ./bootstrap.sh
# RUN ./bootstrap.sh

# FROM chainguard/wolfi-base AS test-wolfi
# COPY ./bootstrap.sh ./bootstrap.sh
# RUN ./bootstrap.sh