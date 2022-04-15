#!/bin/bash

program=$1
prefix=${program:0:1}prof
for fname in $prefix-* ; do
   IFS='-.' read -a strarr <<< "$fname"
   side=${strarr[1]}
   trial=${strarr[2]}
   echo collecting timers for $fname
   cd $fname
   pprof -s | awk 'BEGIN{x=0} /(mean)/,EOF {if(x < 5) x++; else print $7 "," int($6 * $4)}' | sort > timers.tmp
   slow_node=$(pprof | awk '/compute phase/ {print $6} /^NODE/' | sed -e 's/^NODE//' -e 's/;.*$//' | sed -n -e '/^ / {N;s/\n/ /p}' | awk '{print $2,$1}' | sort -n | awk '{print $2}' | tail -1)
   pprof -s {slow_node} | awk '/(mean)/ {printing=1} /compute phase/ {if(printing) print "compute_slow," $6}' >> timers.tmp
   cd ..
   if [ "x$trial" == "x1" ] ; then
        mv ${fname}/timers.tmp ${program}.${side}.timers.csv
   else
       paste -d "," ${program}.${side}.timers.csv <(cut -f 2 -d "," ${fname}/timers.tmp) > tmp.csv
       mv tmp.csv ${program}.${side}.timers.csv
   fi
done

for fname in ${program}*timers.csv ; do
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
