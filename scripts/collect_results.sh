#!/bin/bash

module purge
module load DefApps
module load  gcc/9.1.0
module load tau

export REPRO_DIR=/gpfs/alpine/scratch/pdavis/fus123/benesh-heateq/repro/sc22-benesh-repro

for method in async lockstep ; do
    for scaling in strong weak ; do
        mkdir -p ${REPRO_DIR}/results/${method}/${scaling}
        for size in 64 ; do
            echo collecting results for $method, $scaling scaling, $size processes per component
            cd ${REPRO_DIR}/run/${method}/${scaling}/${size}
            ${REPRO_DIR}/scripts/build_csvs.sh ${size}
            cp traces.res.csv ${REPRO_DIR}/results/${method}/${scaling}/traces.${size}.csv
            cp timers.res.csv ${REPRO_DIR}/results/${method}/${scaling}/timers.${size}.csv
        done
    done
done
