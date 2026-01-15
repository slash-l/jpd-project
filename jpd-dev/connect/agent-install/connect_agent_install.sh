#!/bin/bash

# 检查是否以root用户运行，因为su -c需要root权限或者有sudo权限的用户
if [ "$(id -u)" -ne 0 ]; then
    echo "此脚本需要root权限来执行 'su -c' 命令。"
    echo "请使用 'sudo bash $(basename "$0")' 运行此脚本。"
    exit 1
fi

echo "正在获取设备的MAC地址..."

# 尝试获取第一个非回环接口的MAC地址
# 使用 'ip link show' 命令获取网络接口信息
# 通过 'awk' 过滤出包含 'link/ether' 的行，并提取MAC地址
# 'head -n 1' 确保只取第一个找到的MAC地址
MAC_ADDRESS=$(ip link show | awk '/link\/ether/ {print $2}' | head -n 1)

# 检查是否成功获取到MAC地址
if [ -z "$MAC_ADDRESS" ]; then
    echo "错误：未能获取到设备的MAC地址。请检查网络配置。"
    exit 1
fi

echo "已获取到MAC地址: $MAC_ADDRESS"

# 构建要执行的命令字符串
# 注意：这里需要仔细处理引号，因为整个字符串会传递给 'su -c'
# 外部的单引号用于 'su -c' 的命令参数
# 内部的引号用于 wget 和 sh -s 的参数，特别是 $DEVICE_NAME 的值
# 我们使用双引号来允许 $MAC_ADDRESS 变量的扩展
INSTALL_COMMAND="wget -O - \"https://app.connect.jfrog.io/v2/install_connect\" | sh -s -- -n=\"device_$MAC_ADDRESS\" -g=\"ReadyGroup\" -p=\"<token>\" "

echo "将要执行的命令 (以root权限):"
echo "su -c '$INSTALL_COMMAND'"

# 使用 'su -c' 以root权限执行构建的命令
# 整个 INSTALL_COMMAND 字符串被单引号包裹，确保作为一个整体传递给 su -c
# 这样，变量 $MAC_ADDRESS 的值会在当前脚本中被替换，而不是在 su -c 的环境中
su -c "$INSTALL_COMMAND"

echo "脚本执行完毕。"

