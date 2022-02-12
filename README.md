# win7patch

一键打齐所有 Windows 7 补丁

## 使用方法

1. 在 Windows 10 操作系统上，运行 `buildiso.ps1` 生成 `win7patch.iso` 光盘镜像；
2. 将 `win7patch.iso` 刻录到 DVD，或者复制其中内容至 U 盘；
3. 将制作好的 DVD 或 U 盘插入目标 Windows 7 计算机中，执行其中 `setup.bat` 即可开始安装；
4. 安装过程中计算机会重新启动数次，安装完成后会显示提示信息和安装日志。

# win7patch

One-click to install all Windows 7 patches

## Guide

1. By default, this program will install some Chinese language components (such as .NET language packs and vcredist). If you are using a different language, please search for `XXX` marks in `urls.csv`, `dvd/setup.bat`, `dvd/script.txt` and make corresponding changes.
2. On a computer running Windows 10, run `buildiso.ps1` to generate `win7patch.iso`.
3. Burn `win7patch.iso` to a DVD, or extract its contents to a USB drive.
4. Insert the DVD or USB drive to target Windows 7 machine, run `setup.bat` to begin installation.
5. Computer will restart several times during installation. When finished, a message and installation log will appear on screen.
