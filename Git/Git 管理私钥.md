# 管理 ssh 私钥

## 一、添加私钥

1.Linux 平台：打开终端到 id_rsa 文件所在目录

2.Windows 平台：id_rsa 文件所在目录右键打开 Git Bash Here

```shell
# 终端执行
ssh-add id_rsa

# 如果提示：Could not open a connection to your authentication agent
# 执行下列语句
ssh-agent bash
```

## 二、新建 `config` 文件

文件内容如下：

需要注意的是：`IdentityFile` 指向 id_rsa 文件,不一定非要放在 .ssh 目录

```shell
# github
Host github.com
HostName github.com
PreferredAuthentications publickey
IdentityFile /home/yourname/Documents/ssh/id_rsa
User yourname
```

复制该文件到 ssh 目录：

1.Linux 平台：`/home/yourname/.ssh/`

2.Windows 平台：`/c/Users/yourname/.ssh/`

## 三、测试链接

```shell
ssh -T git@github.com

# 设置 name 与 email
git config --global user.name "name"
git config --global user.email "email"
```

## 附录

对于 Linux 系统，如果是直接复制 config 和 id_rsa 文件多半会收到下列提示：

    Bad owner or permissions on ...
    permissions are too open error

很明显，是权限的问题使得私钥未被接收，所以修改这两个文件的权限即可：

    chmod 400 ~/.ssh/config
    chmod 400 ~/.ssh/id_rsa