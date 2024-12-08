#!/bin/bash

# 设置 GitHub 上 config_files 目录的 URL 基础部分
BASE_URL="https://raw.githubusercontent.com/dagu152/xaryr/refs/heads/main/config_files/"
CONFIG_PATH="/etc/XrayR/config.yml"  # 假设配置文件路径

# 获取 config_files 目录下的所有 .yml 文件
config_files=($(curl -s https://github.com/dagu152/xaryr/refs/heads/main/config_files | grep -oP '(?<=href=")/dagu152/xaryr/refs/heads/main/config_files/.*\.yml(?=")' | sed 's|/dagu152/xaryr/refs/heads/main/config_files/||'))

# 如果没有找到任何 .yml 文件
if [ ${#config_files[@]} -eq 0 ]; then
  echo "没有找到任何 .yml 配置文件！"
  exit 1
fi

# 询问是否开始更新配置文件
while true; do
  echo "按 'q' 快速启动配置更新脚本，或按 'e' 退出:"
  read -n 1 -s key
  echo  # 换行

  if [[ "$key" == "q" || "$key" == "Q" ]]; then
    echo "开始运行配置更新..."
    
    # 显示可选配置文件列表
    echo "请选择要应用的配置文件："
    for i in "${!config_files[@]}"; do
      echo "$((i+1)). ${config_files[$i]}"
    done

    # 选择配置文件
    read -p "请输入数字选择配置文件 (1-${#config_files[@]}): " option

    # 根据输入选择配置文件
    if [[ "$option" -ge 1 && "$option" -le "${#config_files[@]}" ]]; then
      config_file="${config_files[$((option-1))]}"
      echo "你选择了配置文件: $config_file"
    else
      echo "无效选择，退出脚本！"
      exit 1
    fi

    # 更新配置文件
    update_config() {
      echo "正在从 GitHub 拉取配置文件: $config_file..."
      curl -sSL -o "$CONFIG_PATH" "${BASE_URL}${config_file}"
      echo "配置文件 $config_file 更新完成！"
    }

    # 选择是否重启 XrayR
    restart_choice() {
      read -p "是否重启 XrayR？(y/n): " choice
      case $choice in
        y|Y)
          echo "正在重启 XrayR..."
          sudo systemctl restart XrayR
          echo "XrayR 已重启！"
          ;;
        n|N)
          echo "跳过重启 XrayR。"
          ;;
        *)
          echo "无效选择，跳过重启。"
          ;;
      esac
    }

    # 执行更新和重启选择
    update_config
    restart_choice
    break  # 退出循环，脚本执行完毕
  elif [[ "$key" == "e" || "$key" == "E" ]]; then
    echo "退出脚本。"
    exit 0
  else
    echo "无效按键，继续等待..."
  fi
done
