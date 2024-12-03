#!/bin/sh

# 启动 beszel 服务
/beszel serve --http=0.0.0.0:8090 &

# 等待5秒
sleep 5

# 查找 beszel_data 文件夹，并输出路径及其内容
BESZEL_DATA_PATH=$(find / -type d -name "beszel_data" 2>/dev/null)

if [ -n "$BESZEL_DATA_PATH" ]; then
    echo "beszel_data 文件夹路径: $BESZEL_DATA_PATH"
    
    # 遍历 beszel_data 文件夹下的内容
    for item in "$BESZEL_DATA_PATH"/*; do
        if [ -d "$item" ]; then
            echo "目录: $item"
        elif [ -f "$item" ]; then
            echo "文件: $item"
        fi
    done
else
    echo "未找到 beszel_data 文件夹"
fi
