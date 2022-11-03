---
Data: 2022-11-3
---

# Recovery.sh

> 一键部署Hexo环境以及恢复Blog数据

- 支持Ubuntu、Centos7
- 新增支持出现错误终止（使用bash执行脚本，若出现错误将自动退出脚本并且返回状态码，状态码设置为出错的项的行号。）
- 隐藏不必要输出
- 新增`clean`参数（可在脚本执行完毕后清理压缩文件）
- 新增`restart`参数（清理已经安装的nodejs以及解压的数据包）
- 参数支持混合使用（使用案例：bash recovery-blog.sh clean restart）