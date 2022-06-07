
### 脚本无法执行时
1) 检查当前权限
2) 通过Powershell进行如下设置
set-executionpolicy -executionpolicy RemoteSigned # 对远程脚本验证签名
3) 其他几种设置
set-executionpolicy -executionpolicy Restricted # 禁止执行脚本
set-executionpolicy -executionpolicy unrestricted # 不限制

### 脚本打包为二进制
1) 执行 ps1toexe.ps1 脚本, 但是目前该脚本只能支持单个脚本文件, 如果有多个脚本文件将报错
2) 通过IExpress工具打包