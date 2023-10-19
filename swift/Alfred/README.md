#  readme

使用AlfredJSON 转换 json格式

因为在Alfred script-filter 功能中仅支持json格式输入，不能有任何日志，否则会导致识别。
https://www.alfredapp.com/help/workflows/inputs/script-filter/

解决办法：/dev/null 2>&1 
    runner lane hot file tt.json > /dev/null 2>&1 && cat ~/Desktop/tt.json
    /Users/boyer/Runner lane hot file ttt.json > tt.json | cat /Users/boyer/Desktop/ttt.json
第一步： 使用shell 脚本隐藏日志信息
第二步：把json数据保存到文件中
第三步：使用cat 命令，在alfred中打印。

经过测试，前两步可以正常执行，但是cat命令被阻断。出现错误：[Script Filter] Queuing argument '(null)'


使用swift-sh 可以正常运行。



