#!/bin/sh

# 检查必要的环境变量
if [ -z "$R2_ACCESS_KEY_ID" ] || [ -z "$R2_SECRET_ACCESS_KEY" ] || [ -z "$R2_ENDPOINT_URL" ] || [ -z "$R2_BUCKET_NAME" ]; then
    echo "Warning: R2 environment variables are not set, skipping backup/restore"
else
    # 检查是否已经恢复过备份
    if [ -f /beszel_data/.restored ]; then
        echo "Backup has already been restored, skipping restore operation"
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
            cd /beszel_data && unzip -q "/tmp/${LATEST_BACKUP}" || { echo "Failed to unzip backup"; exit 1; }
            rm "/tmp/${LATEST_BACKUP}"
            echo "Backup restored successfully"
            # 创建标志文件，表示备份已经恢复
            touch /beszel_data/.restored
        else
            echo "No backup found in R2, starting with fresh data directory"
        fi
    fi
fi

# 等待5秒
sleep 5

ls /beszel_data

/beszel serve --http=0.0.0.0:8090
