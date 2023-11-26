#!/usr/bin/env bash
#
# 安全配置脚本
# 用于更新系统、配置iptables和ip6tables规则
#

set -e

# 日志函数
note() {
  echo "[$(date)] NOTE: $1"
}

warning() {
  echo "[$(date)] WARNING: $1" >&2
}

error() {
  echo "[$(date)] ERROR: $1" >&2
  exit 1
}

# 检查是否为root用户
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root"
fi

# 更新系统
update_system() {
    note "开始系统更新..."
    apt update && apt upgrade -y
    note "系统更新完成"
}

# 配置iptables和ip6tables规则
configure_firewall() {
    note "开始配置iptables规则"
    apt install iptables-persistent -y

    iptables -F
    iptables -X
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT
    iptables -A INPUT -p udp --dport 8389 -j ACCEPT
    iptables -A INPUT -p udp --dport 20000:50000 -j ACCEPT
    iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -P INPUT DROP
    iptables -P OUTPUT ACCEPT
    iptables -t nat -A PREROUTING -p udp --dport 20000:50000 -j DNAT --to-destination :8389
    iptables -L
    iptables -t nat -nL --line

    note "开始配置ip6tables规则"
    ip6tables -F
    ip6tables -X
    ip6tables -A INPUT -i lo -j ACCEPT
    ip6tables -A INPUT -p tcp --dport 22 -j ACCEPT
    ip6tables -A INPUT -p tcp --dport 80 -j ACCEPT
    ip6tables -A INPUT -p tcp --dport 443 -j ACCEPT
    ip6tables -A INPUT -p udp --dport 8389 -j ACCEPT
    ip6tables -A INPUT -p udp --dport 20000:50000 -j ACCEPT
    ip6tables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    ip6tables -P INPUT DROP
    ip6tables -P OUTPUT ACCEPT
    ip6tables -t nat -A PREROUTING -p udp --dport 20000:50000 -j DNAT --to-destination :8389
    ip6tables -L
    ip6tables -t nat -nL --line

    note "iptables和ip6tables规则配置完成"
}

# 主函数
main() {
  note "开始执行脚本"
  update_system
  configure_firewall
  note "脚本执行完成"
}

main "$@"
