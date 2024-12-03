#!/bin/sh

# 启动 beszel 服务
/beszel serve --http=0.0.0.0:8090 &

# 等待5秒
sleep 5

# 查找 beszel_data 文件夹，并输出路径
BESZEL_DATA_PATH=$(find / -type d -name "beszel_data" 2>/dev/null)

if [ -n "$BESZEL_DATA_PATH" ]; then
    echo "beszel_data 文件夹路径: $BESZEL_DATA_PATH"
else
    echo "未找到 beszel_data 文件夹"
fi
