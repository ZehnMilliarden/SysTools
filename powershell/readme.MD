
### 脚本无法执行时
1) 检查当前权限
2) 通过Powershell进行如下设置
set-executionpolicy -executionpolicy RemoteSigned # 对远程脚本验证签名
3)其他几种设置
set-executionpolicy -executionpolicy Restricted # 禁止执行脚本
set-executionpolicy -executionpolicy unrestricted # 不限制