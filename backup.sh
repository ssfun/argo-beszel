#!/bin/sh

# 检查必要的环境变量
if [ -z "$R2_ACCESS_KEY_ID" ] || [ -z "$R2_SECRET_ACCESS_KEY" ] || [ -z "$R2_ENDPOINT_URL" ] || [ -z "$R2_BUCKET_NAME" ]; then
    echo "Error: Required environment variables are not set"
    echo "Please ensure R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY, R2_ENDPOINT_URL, and R2_BUCKET_NAME are set"
    exit 1
fi

# R2配置
export AWS_ACCESS_KEY_ID="$R2_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$R2_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="auto"
export AWS_ENDPOINT_URL="$R2_ENDPOINT_URL"
export BUCKET_NAME="$R2_BUCKET_NAME"

# 创建备份
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="beszel_backup_${TIMESTAMP}.tar.gz"

# 压缩数据
echo "Starting data compression..."
cd / && tar -czf "/tmp/${BACKUP_FILE}" /beszel_data
if [ $? -eq 0 ]; then
    echo "Data compression completed successfully: /tmp/${BACKUP_FILE}"
else
    echo "Error: Data compression failed"
    exit 1
fi

# 上传到R2
echo "Starting upload to R2..."
aws s3 cp "/tmp/${BACKUP_FILE}" "s3://${BUCKET_NAME}/${BACKUP_FILE}"
if [ $? -eq 0 ]; then
    echo "Upload to R2 completed successfully: s3://${BUCKET_NAME}/${BACKUP_FILE}"
else
    echo "Error: Upload to R2 failed"
    exit 1
fi

# 删除本地临时文件
echo "Removing local temporary file..."
rm "/tmp/${BACKUP_FILE}"
if [ $? -eq 0 ]; then
    echo "Local temporary file removed successfully"
else
    echo "Error: Failed to remove local temporary file"
    exit 1
fi

# 删除7天前的备份
OLD_DATE=$(date -d "7 days ago" +%Y%m%d)
echo "Checking for old backups to delete (older than ${OLD_DATE})..."

# 列出所有备份文件并处理
aws s3 ls "s3://${BUCKET_NAME}/" | grep "beszel_backup_" | while read -r line; do
    # 提取文件名
    backup_file=$(echo "$line" | awk '{print $4}')
    # 从文件名中提取日期部分 (YYYYMMDD)
    backup_date=$(echo "$backup_file" | grep -oP '\d{8}')

    if [ -z "$backup_date" ]; then
        echo "Warning: Could not extract date from file: $backup_file"
        continue
    fi

    echo "Processing file: $backup_file"
    echo "Extracted date: $backup_date"

    # 比较日期
    if [ "$backup_date" -lt "$OLD_DATE" ]; then
        echo "Deleting old backup: $backup_file"
        aws s3 rm "s3://${BUCKET_NAME}/$backup_file"
        if [ $? -eq 0 ]; then
            echo "Old backup deleted successfully: $backup_file"
        else
            echo "Error: Failed to delete old backup: $backup_file"
        fi
    else
        echo "Keeping backup: $backup_file"
    fi
done

echo "Backup process completed successfully"
