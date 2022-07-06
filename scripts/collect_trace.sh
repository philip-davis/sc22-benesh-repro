#!/bin/bash

program=$1
size=$2
prefix=${program:0:1}prof
for fname in $prefix-* ; do
   IFS='-.' read -a strarr <<< "$fname"
   side=${strarr[1]}
   trial=${strarr[2]}
   cd $fname
   echo collecting trace data for $fname
   gunzip *.gz 2>/dev/null
   ${REPRO_DIR}/scripts/get_perf_json.py $2 > trace.tmp
   cd ..
   if [ "x$trial" == "x1" ] ; then
        mv ${fname}/trace.tmp ${program}.${side}.trace.csv
   else
       paste -d "," ${program}.${side}.trace.csv <(cut -f 2,3 -d "," ${fname}/trace.tmp) > tmp.csv
       mv tmp.csv ${program}.${side}.trace.csv
   fi
done

for fname in ${program}*trace.csv ; do
   lines=$(wc $fname | awk '{print $1}')
   echo -n > tmp.csv
   IFS='.' read -a strarr <<< "$fname"
   side=${strarr[1]}
   for iter in $(seq 1 $lines) ; do
        echo "${program},${side}" >> tmp.csv
   done
   paste -d ',' tmp.csv ${fname} > tmp2.csv
   mv tmp2.csv ${fname}
done
