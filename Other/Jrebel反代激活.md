# JRebel 反代激活

JRebel 的社区激活取消了，不能用分享到脸书的方式激活插件了，有点桑心。搜索了一番本地激活方法，于此记录。

## 1 准备工具

* 在 [ilanyu/ReverseProxy](https://github.com/ilanyu/ReverseProxy) 下载工具，相应操作系统选择自己对应的版本。

* 在 [Online GUID Generator](https://www.guidgenerator.com/online-guid-generator.aspx) 获取一串 GUID，记录之。

* IDEA 上在线下载 JRebel 插件。

## 2 激活

* 运行步奏一下载的程序（如果端口冲突参考 GitHub 文档使用帮助）。

* 修改本机 Hosts 文件，对于 Windows 目录为：`C:\Windows\System32\drivers\etc`

    ```shell
    # 任意添加一个网站代理到本地回环上
    127.0.0.1 omg.cc
    ```

* IDEA 中打开 JRebel 的激活界面。URL 处填写 `http://omg.cc:8888/你找的GUID`

## 3 以上

哦，记得将激活类型改为 work offline，离线 180 天，不然每次开还是有些麻烦的。

---

参考资料：

1. https://github.com/ilanyu/ReverseProxy

1. https://www.guidgenerator.com/online-guid-generator.aspx

1. http://blog.lanyus.com/archives/337.html/comment-page-1#comments
