#!/bin/sh

# 设置默认值
R2_ACCESS_KEY_ID=${R2_ACCESS_KEY_ID:-""}
R2_SECRET_ACCESS_KEY=${R2_SECRET_ACCESS_KEY:-""}
R2_ENDPOINT_URL=${R2_ENDPOINT_URL:-""}
R2_BUCKET_NAME=${R2_BUCKET_NAME:-""}

# 检查必要的环境变量
if [ -z "$R2_ACCESS_KEY_ID" ] || [ -z "$R2_SECRET_ACCESS_KEY" ] || [ -z "$R2_ENDPOINT_URL" ] || [ -z "$R2_BUCKET_NAME" ]; then
    echo "Warning: R2 environment variables are not set, skipping backup/restore"
    exit 0
fi

# R2配置
export AWS_ACCESS_KEY_ID="$R2_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$R2_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="auto"
export AWS_ENDPOINT_URL="$R2_ENDPOINT_URL"
export BUCKET_NAME="$R2_BUCKET_NAME"

# 恢复功能
restore_backup() {
    echo "Checking for latest backup in R2..."
    LATEST_BACKUP=$(aws s3 ls "s3://${BUCKET_NAME}/beszel_backup_" | sort | tail -n 1 | awk '{print $4}' || echo "")
    
    if [ -n "$LATEST_BACKUP" ]; then
        echo "Found backup: ${LATEST_BACKUP}"
        echo "Downloading and restoring backup..."
        aws s3 cp "s3://${BUCKET_NAME}/${LATEST_BACKUP}" /tmp/ || true
        if [ -f "/tmp/${LATEST_BACKUP}" ]; then
            cd / && tar -xzf "/tmp/${LATEST_BACKUP}"
            rm "/tmp/${LATEST_BACKUP}"
            echo "Backup restored successfully"
        else
            echo "Failed to download backup"
        fi
    else
        echo "No backup found in R2, starting with fresh data directory"
    fi
}

# 备份功能
create_backup() {
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="beszel_backup_${TIMESTAMP}.tar.gz"

    # 压缩数据
    echo "Starting data compression..."
    cd / && tar -czf "/tmp/${BACKUP_FILE}" /beszel_data
    if [ $? -ne 0 ]; then
        echo "Error: Data compression failed"
        return 1
    fi
    echo "Data compression completed successfully: /tmp/${BACKUP_FILE}"

    # 上传到R2
    echo "Starting upload to R2..."
    aws s3 cp "/tmp/${BACKUP_FILE}" "s3://${BUCKET_NAME}/${BACKUP_FILE}"
    if [ $? -ne 0 ]; then
        echo "Error: Upload to R2 failed"
        rm "/tmp/${BACKUP_FILE}"
        return 1
    fi
    echo "Upload to R2 completed successfully"

    # 清理临时文件
    rm "/tmp/${BACKUP_FILE}"
    echo "Local temporary file removed successfully"

    # 删除旧备份
    echo "Cleaning up old backups older than 7 days..."
    # 计算7天前的日期
    if date --date="7 days ago" +%Y%m%d >/dev/null 2>&1; then
        OLD_DATE=$(date --date="7 days ago" +%Y%m%d)
    else
        OLD_DATE=$(date -d "7 days ago" +%Y%m%d 2>/dev/null || echo "00000000")
    fi
    echo "Cutoff date for old backups: ${OLD_DATE}"

    # 列出所有备份文件并检查日期
    aws s3 ls "s3://${BUCKET_NAME}/beszel_backup_" | while read -r line; do
        BACKUP_FILE=$(echo "$line" | awk '{print $4}')
        if [ -n "$BACKUP_FILE" ]; then
            # 提取日期部分 (格式: beszel_backup_YYYYMMDD_HHMMSS.tar.gz)
            BACKUP_DATE=$(echo "$BACKUP_FILE" | sed -e 's/.*beszel_backup_\([0-9]\{8\}\).*/\1/')
            if [ -n "$BACKUP_DATE" ] && [ "$BACKUP_DATE" != "$BACKUP_FILE" ]; then
                if [ "$BACKUP_DATE" -lt "$OLD_DATE" ] 2>/dev/null; then
                    echo "Deleting old backup: $BACKUP_FILE (Date: $BACKUP_DATE)"
                    aws s3 rm "s3://${BUCKET_NAME}/$BACKUP_FILE"
                fi
            fi
        fi
    done
    
    echo "Backup process completed successfully!"
}

# 根据参数执行不同的操作
case "$1" in
    "restore")
        restore_backup
        ;;
    "backup")
        create_backup
        ;;
    *)
        echo "Usage: $0 {backup|restore}"
        exit 1
        ;;
esac
