FROM alpine AS test-alpine
USER test
RUN ./bootstrap.sh

FROM ubuntu AS test-ubuntu
USER test
RUN ./bootstrap.sh

FROM wolfi AS test-wolfi
USER test
RUN ./bootstrap.sh