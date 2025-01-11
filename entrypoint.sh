#!/bin/sh

# 设置默认值
CF_TOKEN=${CF_TOKEN:-""}

# 配置定时备份任务
echo "Setting up backup cron job..."
echo "0 2,14 * * * /backup.sh backup >> /var/log/backup.log 2>&1" > /var/spool/cron/crontabs/root

# 尝试恢复备份
/backup.sh restore

# 启动 crond
echo "Starting crond ..."
crond

# 启动 cloudflared
if [ -n "$CF_TOKEN" ]; then
    echo "Starting cloudflared..."
    cloudflared --no-autoupdate tunnel run --protocol http2 --token "$CF_TOKEN" >/dev/null 2>&1 &
else
    echo "Warning: CF_TOKEN is not set, skipping cloudflared"
fi

# 启动 beszel 服务
echo "Starting beszel..."
exec /beszel serve --http=0.0.0.0:8090
