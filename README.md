# MEM_DAGGER

ADB 数据拉取及辅助诊断工具

## 使用方式
1. 在`Bash`中执行 `./mmonitor ${进程特征}` 会生成一个 `${包名}-${日期}` 的目录

2. 通过检查目录中的各个文件来分析当前的内存占用情况

3. 各文件内容如下
  * `procrank-${TIME}.log` 各进程所占用的内存排行及总体情况
    * 什么是 `VSS, RSS, PSS, USS`
      * `VSS` 进程所能访问到的所有内存尺寸
      * `RSS` 进程本身占用内存尺寸 + 共享库内存尺寸
      * `PSS` 进程本身占用内存尺寸 + 共享库内存尺寸/使用共享库的进程数量
      * `USS` 进程本身占用内存尺寸

  * `mem-all-${TIME}.log`  所有应用当前内存使用情况

  * `mem-pkg-${TIME}.log` 指定进程当前内存使用情况

  * `android-${TIME}.hprof` Android 堆快照, 可以用 **AndroidStudio** 的 **Profiler** 解析工具帮助查看

  * `java-${TIME}.hprof` Java 堆快照, 可以用 **MemoryAnalyzerTool** 帮助查看
    * [Android AndroidStudio - HPROF文件查看和分析工具.pdf](Android Studio - HPROF文件查看和分析工具 - 新感觉 - 博客园.pdf) 解释了如何通过HPROF堆快照分析内存使用情况
    * [mat.zip](mat.zip) 检查 Java 堆快照的工具
