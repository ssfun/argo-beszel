#!/bin/sh

ls /

cd /beszel && ls

cd /

# 检查必要的环境变量
if [ -z "$R2_ACCESS_KEY_ID" ] || [ -z "$R2_SECRET_ACCESS_KEY" ] || [ -z "$R2_ENDPOINT_URL" ] || [ -z "$R2_BUCKET_NAME" ]; then
    echo "Warning: R2 environment variables are not set, skipping backup/restore"
else
    # 配置R2环境变量
    export AWS_ACCESS_KEY_ID="$R2_ACCESS_KEY_ID"
    export AWS_SECRET_ACCESS_KEY="$R2_SECRET_ACCESS_KEY"
    export AWS_DEFAULT_REGION="auto"
    export AWS_ENDPOINT_URL="$R2_ENDPOINT_URL"
    export BUCKET_NAME="$R2_BUCKET_NAME"

    # 尝试从R2恢复最新备份
    echo "Checking for latest backup in R2..."
    LATEST_BACKUP=$(aws s3 ls "s3://${BUCKET_NAME}/@auto_pb_backup_beszel_" | sort | tail -n 1 | awk '{print $4}')

    if [ ! -z "$LATEST_BACKUP" ]; then
        echo "Found backup: ${LATEST_BACKUP}"
        echo "Downloading and restoring backup..."
        aws s3 cp "s3://${BUCKET_NAME}/${LATEST_BACKUP}" /tmp/ || { echo "Failed to download backup"; exit 1; }
        rm -rf /beszel/beszel_data/*  # 确保删除的是正确的目录
        mkdir -p /beszel/beszel_data  # 确保目录存在
        cd /beszel/beszel_data && unzip -q "/tmp/${LATEST_BACKUP}" || { echo "Failed to unzip backup"; exit 1; }
        rm "/tmp/${LATEST_BACKUP}"
        echo "Backup restored successfully"
    else
        echo "No backup found in R2, starting with fresh data directory"
    fi
fi

# 启动 beszel 服务
/beszel serve --http=0.0.0.0:8090
