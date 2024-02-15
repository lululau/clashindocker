from alpine

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.sjtug.sjtu.edu.cn/g' /etc/apk/repositories
RUN apk update && \
    apk add --no-cache busybox-suid curl iptables tzdata&& \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone \
    rm -rf /var/cache/apk/*

WORKDIR /opt/clash
COPY clash/  .
RUN chmod +x *.sh

# 复制 crontab 文件并设置文件权限
COPY  clash/crontab /var/spool/cron/crontabs/root
RUN chmod 0600 /var/spool/cron/crontabs/root

CMD ["sh", "-c", " ./run.sh"]
