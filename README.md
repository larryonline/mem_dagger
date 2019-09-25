# MEM_DAGGER

ADB 数据拉取及辅助诊断工具

## 使用方式

1. 执行各平台对应的脚本回生成一个`${包名}-${日期}` 的目录
    * **MAC** 在`Bash`中执行 `${脚本所在目录}/mac.sh ${进程特征}`
        * 例子: 我想检查一个包名为 "me.zhennan.Example1" 的应用. 我使用以下任意方式执行 `mac.sh`
          * `${脚本所在目录}/mac.sh Example1`
          * `${脚本所在目录}/mac.sh me.zhennan.Example1`
    * `暂未实现` **WINDOWS** 在`cmd`中执行`${脚本所在目录}/windows.bat ${进程特征}`
        * 例子: 我想检查一个包名为 "me.zhennan.Example1" 的应用, 可以使用以下任意方式执行 `windows.bat`
          * `${脚本所在目录}/windows.bat Example1`
          * `${脚本所在目录}/windows.bat me.zhennan.Example1`

2. 通过检查目录中的各个文件来分析当前的内存占用情况

3. 各文件内容如下
    * `procrank-${TIME}.log` 各进程所占用的内存排行及总体情况
      * 什么是 `VSS, RSS, PSS, USS`
        * `VSS` 进程所能访问到的所有内存尺寸
        * `RSS` 进程本身占用内存尺寸 **➕** 共享库内存尺寸
        * `PSS` 进程本身占用内存尺寸 **➕** 共享库内存尺寸 **➗** 使用共享库的进程数量
        * `USS` 进程本身占用内存尺寸

  * `mem-all-${TIME}.log`  所有应用当前内存使用情况

  * `mem-pkg-${TIME}.log` 指定进程当前内存使用情况

  * `android-${TIME}.hprof` Android 堆快照, 可以用 **AndroidStudio** 的 **Profiler** 解析工具帮助查看

  * `java-${TIME}.hprof` Java 堆快照, 可以用 **MemoryAnalyzerTool** 帮助查看

  * [mat.zip](./tool/mat.zip) 检查 Java 堆快照的工具
