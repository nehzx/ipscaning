FROM golang:alpine AS builder

LABEL maintainer "nehza <azhen@nehza.com>"

WORKDIR /root

RUN apk --no-cache add git && git clone https://github.com/XIU2/CloudflareSpeedTest.git && cd CloudflareSpeedTest && go build

FROM alpine 

WORKDIR /root

COPY --from=builder  /root/CloudflareSpeedTest/CloudflareSpeedTest .
COPY --from=builder  /root/CloudflareSpeedTest/ip.txt .
COPY run.sh .

ENV TZ=Asia/Shanghai 
ENV AS=
ENV FEISHU_WEB_HOOK=

RUN apk --no-cache add bash curl tzdata \
    && chmod +x /root/run.sh \
    && echo '30 22 * * *  bash /root/run.sh' > /etc/crontabs/root \
    && echo "${TZ}" > /etc/timezone \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime 

ENTRYPOINT ["/usr/sbin/crond", "-f"]



