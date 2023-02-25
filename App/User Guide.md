# User Guide

#### - MATLAB PTB与App设置

1. 安装MATLAB 2020b及以上版本
2. 将`Psychtoolbox`和`Gstreamer`文件夹放在合适位置
3. 右键我的电脑-属性-高级系统设置-环境变量-系统变量-新建

> 变量名: `GSTREAMER_1_0_ROOT_MSVC_X86_64`
>
> 变量值: `根路径\gstreamer\1.0\msvc_x86_64\`

4. 在MATLAB中打开`根路径\Psychtoolbox-3-3.xx\Psychtoolbox`，打开运行`SetupPsychtoolbox.m`。MATLAB命令行中若无`Screen()无法使用`的相关提示则表明配置完成，否则检查`Gstreamer`的安装（可自行另外下载安装`PTB`和`Gstreamer`，配置方法相同）
5. 运行`for_redistribution`文件夹下的`MyAppInstaller.mcr`完成`MATLAB_runtime`的本地安装
6. 运行`for_redistribution_files_only`文件夹下的`MyApp.exe`即可



#### - io64并口设置

1. 将`MATLAB LTP Config`文件夹下的`inpoutx64.dll`和`inpoutx64.sys`文件复制或移动至`C:\Windows\System32\`目录下
2. 将`MATLAB LTP Config`下的`config_io.m`、`inp.m`、`outp.m`和`io64.mexw64`加入MATLAB的路径
3. 在MATLAB中运行`config_io.m`成功则表示配置完成

