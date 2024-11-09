#!/usr/bin/env bash
#
# 通用安全配置脚本
# 支持多个Linux发行版和CPU架构
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

# 检测系统信息
CPU_ARCH="$(uname -m)"
KERNEL_VERSION="$(uname -r)"
OS=$(grep '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
note "检测到系统: $OS, CPU架构: $CPU_ARCH, 内核版本: $KERNEL_VERSION"

# 根据发行版选择包管理器和防火墙持久化工具
case "$OS" in
  ubuntu|debian)
    PACKAGE_MANAGER="apt"
    FIREWALL_PERSIST="iptables-persistent"
    INSTALL_CMD="apt update && apt upgrade -y && apt install -y"
    REMOVE_CMD="apt remove -y"
    ;;
  centos|rhel|fedora)
    PACKAGE_MANAGER="yum"
    FIREWALL_PERSIST="iptables-services"
    INSTALL_CMD="yum install -y"
    REMOVE_CMD="yum remove -y"
    ;;
  arch)
    PACKAGE_MANAGER="pacman"
    FIREWALL_PERSIST="iptables"
    INSTALL_CMD="pacman -Syu --noconfirm"
    REMOVE_CMD="pacman -R --noconfirm"
    ;;
  *)
    error "不支持的Linux发行版: $OS"
    ;;
esac

# 更新系统
update_system() {
    note "开始系统更新..."
    $INSTALL_CMD
    note "系统更新完成"
}

# 安装sudo，删除vim-common，安装vim
install_software() {
    note "检查并安装sudo"
    $INSTALL_CMD sudo

    note "删除vim-common"
    $REMOVE_CMD vim-common || true  # 如果没有vim-common不报错

    note "安装vim"
    $INSTALL_CMD vim
}

# 添加普通用户并赋予sudo权限
add_user() {
    note "添加用户并赋予sudo权限"
    read -p "请输入要添加的用户名: " username
    useradd -m -s /bin/bash "$username"
    passwd "$username"
    usermod -aG sudo "$username"
    sudo -l -U "$username"
    note "用户$username添加完成并已赋予sudo权限"
}

# 配置iptables和ip6tables规则
configure_firewall() {
    note "开始配置防火墙规则"
    $INSTALL_CMD $FIREWALL_PERSIST

    iptables -F
    iptables -X
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -p tcp --dport 8283 -j ACCEPT
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT
    iptables -A INPUT -p udp --dport 8389 -j ACCEPT
    iptables -A INPUT -p udp --dport 15951 -j ACCEPT
    iptables -A INPUT -p udp --dport 20000:50000 -j ACCEPT
    iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -P INPUT DROP
    iptables -P OUTPUT ACCEPT
    iptables -t nat -A PREROUTING -p udp --dport 20000:50000 -j DNAT --to-destination :8389

    ip6tables -F
    ip6tables -X
    ip6tables -A INPUT -i lo -j ACCEPT
    ip6tables -A INPUT -p tcp --dport 8283 -j ACCEPT
    ip6tables -A INPUT -p tcp --dport 80 -j ACCEPT
    ip6tables -A INPUT -p tcp --dport 443 -j ACCEPT
    ip6tables -A INPUT -p udp --dport 8389 -j ACCEPT
    ip6tables -A INPUT -p udp --dport 15951 -j ACCEPT
    ip6tables -A INPUT -p udp --dport 20000:50000 -j ACCEPT
    ip6tables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    ip6tables -P INPUT DROP
    ip6tables -P OUTPUT ACCEPT
    ip6tables -t nat -A PREROUTING -p udp --dport 20000:50000 -j DNAT --to-destination :8389

    note "保存防火墙规则"
    if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
        netfilter-persistent save
    elif [[ "$OS" == "centos" || "$OS" == "rhel" || "$OS" == "fedora" ]]; then
        systemctl enable $FIREWALL_PERSIST
        systemctl start $FIREWALL_PERSIST
    elif [[ "$OS" == "arch" ]]; then
        iptables-save > /etc/iptables/iptables.rules
        ip6tables-save > /etc/iptables/ip6tables.rules
        systemctl enable $FIREWALL_PERSIST
    fi
    note "iptables和ip6tables规则配置完成"
}

# 主函数
main() {
  note "开始执行脚本"
  update_system
  install_software
  add_user
  configure_firewall
  note "脚本执行完成"
}

main "$@"
