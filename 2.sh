#!/bin/bash

# GitHub 上托管的 YML 文件基础 URL（修改为你的 GitHub 仓库路径）
GITHUB_BASE_URL="https://raw.githubusercontent.com/dagu152/xaryr/refs/heads/main/config_files"

# 提示用户输入 YML 文件名
echo "请输入要替换的配置文件名 (例如 hk.yml)："
read -p "文件名: " CONFIG_FILE

# 检查输入是否为空
if [ -z "$CONFIG_FILE" ]; then
  echo "文件名不能为空，脚本退出."
  exit 1
fi

# 构造完整的 GitHub 文件 URL
GITHUB_URL="$GITHUB_BASE_URL/$CONFIG_FILE"

# 输出选择的文件
echo "正在下载 $CONFIG_FILE 并替换配置文件..."

# 使用 curl 下载选中的 YML 文件并覆盖到 /etc/XrayR/config.yml
curl -s -o /etc/XrayR/config.yml "$GITHUB_URL"

# 检查文件是否替换成功
if [ $? -eq 0 ]; then
  echo "配置文件已成功替换为 $CONFIG_FILE"
else
  echo "下载或替换配置文件时出错，请检查网络连接或文件权限."
  exit 1
fi

# 重启 XrayR 服务（假设你已经安装并配置了 systemd）
echo "正在重启 XrayR 服务..."
systemctl restart XrayR

# 检查服务是否成功重启
if [ $? -eq 0 ]; then
  echo "XrayR 服务已成功重启."
else
  echo "重启 XrayR 服务失败，请检查服务状态."
  exit 1
fi
