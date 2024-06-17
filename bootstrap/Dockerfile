FROM golang:1.22.4-bookworm AS builder
WORKDIR /build
COPY bootstrap.go bootstrap.go
COPY go.mod go.mod

RUN CGO_ENABLED=0 go build -o bootstrap -ldflags "-s -w"

RUN ls -alh

FROM alpine AS test-alpine
WORKDIR /root
COPY --from=builder --chmod=u+x /build/bootstrap bootstrap
RUN ./bootstrap

COPY test_bootstrap.sh test_bootstrap.sh
RUN ls -al
RUN ./test_bootstrap.sh

FROM alpine AS test-alpine-pasteable
WORKDIR /root
COPY --from=builder --chmod=u+x /build/bootstrap bootstrap-original
COPY ./pasteable_pre.sh ./pasteable_pre.sh
COPY ./pasteable_post.sh ./pasteable_post.sh
RUN cat ./bootstrap-original | base64 > ./bootstrap-b64-original
RUN cat ./pasteable_pre.sh ./bootstrap-b64-original ./pasteable_post.sh > ./bootstrap-pasteable
RUN chmod u+x ./bootstrap-pasteable
RUN ./bootstrap-pasteable

COPY test_bootstrap.sh test_bootstrap.sh
RUN ./test_bootstrap.sh
