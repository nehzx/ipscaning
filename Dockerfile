FROM golang:alpine AS builder

LABEL maintainer "nehza <azhen@nehza.com>"

WORKDIR /root

RUN apk --no-cache add git && git clone https://github.com/XIU2/CloudflareSpeedTest.git && cd CloudflareSpeedTest && go build

FROM alpine 

WORKDIR /root

COPY --from=builder  /root/CloudflareSpeedTest/CloudflareSpeedTest .
COPY run.sh .

RUN apk --no-cache add bash curl \
    && chmod +x /root/run.sh \
    && echo '30 22 * * *  ./root/run.sh' > /etc/crontabs/root 

ENV AS=
ENV FEISHU_WEB_HOOK=
ENTRYPOINT ["/usr/sbin/crond", "-f"]



