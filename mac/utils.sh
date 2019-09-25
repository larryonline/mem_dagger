#!/usr/bin/env bash

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
