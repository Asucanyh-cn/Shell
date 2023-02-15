---
title: 脚本汇总
date: 2022-11-3
---



仓库

> [脚本报错](https://lptexas.top/posts/2815769597/#%E5%AE%89%E8%A3%85kali)
>
> tips:如果出现`$'\r'`错误，请尝试使用vi命令编辑文件，按ESC进入命令模式，输入`: set ff=unix`。

# start.sh

> 用于Termux启动sshd,nginx & php-fpm,syncthing等服务。

参数

- help 参考详细参数
- all 重启所有服务
- 1 sshd
- 2 nginx & php-fpm
- 3 syncthing

# Recovery.sh

> 一键部署Hexo环境以及恢复Blog数据

- 支持Ubuntu、Centos7
- 新增支持出现错误终止（使用bash执行脚本，若出现错误将自动退出脚本并且返回状态码，状态码设置为出错的项的行号。）
- 隐藏不必要输出
- 新增`clean`参数（可在脚本执行完毕后清理压缩文件）
- 新增`restart`参数（清理已经安装的nodejs以及解压的数据包）
- 参数支持混合使用（使用案例：bash recovery-blog.sh clean restart）