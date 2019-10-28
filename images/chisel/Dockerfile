FROM golang:1.13-alpine as build

ARG OPTS
ARG VERSION

RUN apk add git \
    && mkdir -p src/github.com/jpillora \
    && git -C src/github.com/jpillora clone https://github.com/jpillora/chisel \
    && cd src/github.com/jpillora/chisel \
    && git checkout ${VERSION} \
    && env ${OPTS} CGO_ENABLED=0 GOOS=linux go build -mod vendor -ldflags "-s -w \
      -X github.com/jpillora/chisel/share.BuildVersion=$(git describe --abbrev=0 --tags)" \
      -a -installsuffix cgo -o chisel . && \
      addgroup --system app && \
      adduser --system --ingroup app app && \
      mkdir /scratch-tmp

FROM scratch

COPY --from=build /etc/passwd /etc/group /etc/
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build --chown=app:app /scratch-tmp /tmp/
COPY --from=build /go/src/github.com/jpillora/chisel/chisel .

USER app

ENTRYPOINT ["./chisel"]