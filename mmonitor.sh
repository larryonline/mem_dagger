#!/usr/bin/env bash

# MMonitor is for Memory leak detection.

TODAY="$(date +%Y%m%d)"
NOW="$(date +%H%M%S)"
ROOT=$(cd "$(dirname "$0")";pwd);

# adb should installed already
if ! [ -x "$(command -v adb)" ]; then
  echo "The adb not exist. please install it firstly." >&2
  exit 1
fi

if ! [ -n "$(adb devices | grep device)" ]; then
  echo "Device not exist. please connect to HU." >&2
  exit 1
fi

# hprof-conv should installed already
if ! [ -x "$(command -v hprof-conv)" ]; then
  echo "The hprof-conv not exist. please install it firstly." >&2
fi


# TODO-CHECK: adb devices should connected already
PS_ROW="$(adb shell ps -ef | grep $1 | grep -v grep)"

if [ -z "$PS_ROW" ]; then
  echo "Process not exist. please run it firstly."
  exit 1
fi


# Find PID for given package
echo $(adb shell ps -ef | grep $1 | grep -v grep)
PID=$(adb shell ps -ef | grep $1 | grep -v grep | awk '{print $2}')
PKG=$(adb shell ps -ef | grep $1 | grep -v grep | awk '{print $8}')
echo "PID: $PID, PKG: $PKG";


DIST_FOLDER="$(pwd)/$PKG-$TODAY"
if ! [ -d "$DIST_FOLDER" ]; then
  echo "Create logs folder: $DIST_FOLDER"
  mkdir -p $DIST_FOLDER
fi

DIST_PROCRANK="$DIST_FOLDER/procrank-$NOW.log"
DIST_MEMINFO_ALL="$DIST_FOLDER/meminfo-all-$NOW.log"
DIST_MEMINFO_PKG="$DIST_FOLDER/meminfo-pkg-$NOW.log"
DIST_HPROF="$DIST_FOLDER/android-$NOW.hprof"
DIST_CONVERTED_HPROF="$DIST_FOLDER/java-$NOW.hprof"

TEMP_FOLDER="/data/local/tmp";
TEMP_PROCRANK="$TEMP_FOLDER/prorank.log"
TEMP_MEMINFO_ALL="$TEMP_FOLDER/mem-all.log"
TEMP_MEMINFO_PKG="$TEMP_FOLDER/mem-$PKG.log"
TEMP_HPROF="$TEMP_FOLDER/hprof-unconvered-$NOW.hprof"


if [ -n "$(adb shell command -v procrank)" ]; then
  echo "Retrieve Procrank"
  adb shell "procrank -o > $TEMP_PROCRANK"
  echo "Pull procrank from: $TEMP_PROCRANK to: $DIST_PROCRANK"
  adb pull $TEMP_PROCRANK $DIST_PROCRANK
  adb shell "rm -rf $TEMP_PROCRANK"
fi

if [ -n "$(adb shell command -v dumpsys)" ]; then
  echo "Retrieve system meminfo & package meminfo"
  adb shell "dumpsys meminfo --oom > $TEMP_MEMINFO_ALL"
  adb shell "dumpsys meminfo $PID > $TEMP_MEMINFO_PKG"
  echo "Pull meminfo-all from: $TEMP_MEMINFO_ALL to: $DIST_MEMINFO_ALL"
  adb pull $TEMP_MEMINFO_ALL $DIST_MEMINFO_ALL
  echo "Pull meminfo-pkg from: $TEMP_MEMINFO_PKG to: $TEMP_MEMINFO_PKG"
  adb pull $TEMP_MEMINFO_PKG $DIST_MEMINFO_PKG
  adb shell "rm -rf $TEMP_MEMINFO_ALL $TEMP_MEMINFO_PKG"
fi



wait4HProf() {
  # wait for file to stabalize at a size above 0
  local lastSize=0
  local matchCount=0
  while [ ${matchCount} -lt 3 ] ;
  do
      if [[ ${lastSize} -gt 0 && $(hprofSize) = ${lastSize} ]] ;
          then
          let "matchCount+=1"
          echo "match ${matchCount}"
      else
          matchCount=0
          lastSize=$(hprofSize)
          echo "Dumping file...current size = ${lastSize}"
      fi
      sleep 0.5
  done
  echo "Heap Dump Complete, file size = ${lastSize}"
}

hprofSize() {
  local size=$(echo $(adb shell "ls -s $TEMP_HPROF") | cut -f1 -d' ')
  echo $size
}


if [ -n "$(adb shell command -v am)" ]; then

  echo "Retrieve hprof"
  adb shell "am dumpheap $PID $TEMP_HPROF"
  wait4HProf
  echo "Pull hprof from: $TEMP_HPROF to: $DIST_HPROF"
  adb pull $TEMP_HPROF $DIST_HPROF
  adb shell rm -rf $TEMP_HPROF


  echo "Convert android hprof to java hprof: $DIST_HPROF -> $DIST_CONVERTED_HPROF"
  hprof-conv $DIST_HPROF $DIST_CONVERTED_HPROF
fi
