FROM alpine

RUN set -ex; apk add postgresql

CMD ["/bin/sh", "-c", "trap : TERM INT; (while true; do sleep 1000; done) & wait"]