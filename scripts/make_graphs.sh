#!/bin/bash

export REPRO_DIR=/gpfs/alpine/scratch/pdavis/fus123/benesh-heateq/repro/sc22-benesh-repro

for method in async lockstep ; do
    for scaling in strong weak ; do
        echo 'making graphs for ${method}/${scaling}'
        cd ${REPRO_DIR}/results/${method}/${scaling}
        ${REPRO_DIR}/scripts/make_combo_graphs.py > ${method}_${scaling}.csv
    done
done
