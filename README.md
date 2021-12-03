fastlane documentation
================
# 安装

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
brew install fastlane 
//或
[sudo] gem install fastlane -NV
```

# Runner 用法
## iOS
### ios custom_lane
```
fastlane ios custom_lane
```
Description of what the lane does

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

- 单元测试：可执行程序 不支持unit单元测试
    通过新建一个通用库（工具类，常用方法等），例如：cmdlib，配合单元测试。
- 集成Quick框架，使用单元测试联调swift脚本：例如 求：两个集合的差集
    使用单元测试描述场景，测试用例驱动开发
  - 遗留问题：Nimbe 单元测试没有提示，需要解决。
  - 用例思维：学会测试行为，达到单元测试精确定位。  
- 补齐提示：swift repl 交互下，支持Tab快捷键 打印补齐提示
- swiftPM命令：spi --type 高级使用。创建管理 Framework库，可执行文件。

    
