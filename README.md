# Beszel R2 项目

## 简介

为 [Beszel](https://github.com/henrygd/beszel) 提供一个可扩展的服务，支持数据备份和恢复功能。使用 AWS S3 兼容的存储服务（如 Cloudflare R2）来存储备份数据，并提供自动化的备份和恢复机制。

## 功能特点

- **自动备份**：每天凌晨2点自动备份数据到指定的 S3 兼容存储服务。
- **自动恢复**：在启动容器时，自动从 S3 兼容存储服务中恢复最新的备份数据。
- **灵活配置**：支持通过环境变量配置 S3 兼容存储服务的访问信息。
- **易于部署**：可以在线上容器平台进行部署，简化安装和配置过程。

## 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/yourusername/beszel.git
cd beszel
```

### 2. 构建 Docker 镜像

```bash
docker build -t beszel .
```

### 3. 运行容器

```bash
docker run -d \
  -e R2_ACCESS_KEY_ID="your_access_key_id" \
  -e R2_SECRET_ACCESS_KEY="your_secret_access_key" \
  -e R2_ENDPOINT_URL="https://your-r2-endpoint" \
  -e R2_BUCKET_NAME="your_bucket_name" \
  -p 8090:8090 \
  beszel
```

### 4. 访问服务

打开浏览器，访问 `http://localhost:8090`，即可开始使用 Beszel 服务。

## 环境变量

| 变量名                  | 描述                        | 示例值                          |
|-------------------------|-----------------------------|---------------------------------|
| `R2_ACCESS_KEY_ID`       | R2 访问密钥 ID               | `AKIAIOSFODNN7EXAMPLE`          |
| `R2_SECRET_ACCESS_KEY`   | R2 访问密钥                  | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `R2_ENDPOINT_URL`        | R2 端点 URL                  | `https://your-r2-endpoint`      |
| `R2_BUCKET_NAME`         | R2 存储桶名称                | `your-bucket-name`              |

## 备份与恢复

### 备份

Beszel 项目会每天凌晨2点自动备份数据到指定的 S3 兼容存储服务。备份文件将存储在指定的存储桶中，并以 `beszel_backup_` 为前缀命名。

### 恢复

在容器启动时，Beszel 会自动检查并恢复最新的备份数据。如果找到最新的备份文件，系统会自动下载并解压到 `/beszel_data` 目录中。

## 许可证

本项目采用 MIT 许可证。有关更多信息，请参阅 [LICENSE](LICENSE) 文件。
