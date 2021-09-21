# zSound 遵循gpl3.0开源协议

zSound是从游戏引擎剥离而出的跨平台音频引擎，它支持所有桌面和手机平台

详见使用文档 https://github.com/PassByYou888/zSound/tree/master/document


## 开发平台支持

- Delphi及IDE要求：Delphi Rad studio XE10.2.1 or Last
- FPC编译器支持:FPC3.0.4 or last,可参看本项目随附的[IOT入手指南](https://github.com/PassByYou888/ZServer4D/blob/master/Documents/%E5%85%A5%E6%89%8BIOT%E7%9A%84%E5%AE%8C%E5%85%A8%E6%94%BB%E7%95%A5.pdf)将FPC升级至github最新的版本
- CodeTyphon 6.0 or last（尽量使用Online更新到最新的Cross工具链+相关库）

## CPU架构支持，test with Delphi 11/lazarus 3.2.0

- MIPS(fpc-little endian), soft float, test pass on QEMU 
- intel X86(fpc-x86), soft float
- intel X86(delphi+fpc), hard float,80386,PENTIUM,PENTIUM2,PENTIUM3,PENTIUM4,PENTIUMM,COREI,COREAVX,COREAVX2
- intel X64(fpc-x86_64), soft float
- intel X64(delphi+fpc), hard float,ATHLON64,COREI,COREAVX,COREAVX2
- ARM(fpc-arm32-eabi,soft float):ARMV3,ARMV4,ARMV4T,ARMV5,ARMV5T,ARMV5TE,ARMV5TEJ
- ARM(fpc-arm32-eabi,hard float):ARMV6,ARMV6K,ARMV6T2,ARMV6Z,ARMV6M,ARMV7,ARMV7A,ARMV7R,ARMV7M,ARMV7EM
- ARM(fpc-arm64-eabi,hard float):ARMV8，aarch64


# 更新日志

### 2021-9-22

- 更新了基础库，如果发现不能编译这种问题，给我说声

### 2020-3

- 内核更新
- ZDB数据升级
- bass引擎新增Android-armv8 64位支持

### 2018-5-21

- 修复zSound的应用程序在关闭时报告异常的问题
- 大量基础库更新

### 2018-4-12

修复内核中的内存越界bug：该bug的症状为无故提示内存无法访问，通过正常debug很难排除，这是是内存越界时所造成的bug



- create by.qq600585

