#!/bin/bash

rm -f *.csv

${REPRO_DIR}/scripts/collect_timers.sh adhoc
${REPRO_DIR}/scripts/collect_trace.sh adhoc $1
${REPRO_DIR}/scripts/collect_timers.sh benesh
${REPRO_DIR}/scripts/collect_trace.sh benesh $1
${REPRO_DIR}/scripts/collect_timers.sh dspaces
${REPRO_DIR}/scripts/collect_trace.sh dspaces $1

cat *.trace.csv  >> traces.res.csv
cat *.timers.csv >> timers.res.csv
