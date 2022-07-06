#!/bin/bash

export REPRO_DIR=/gpfs/alpine/scratch/pdavis/fus123/benesh-heateq/repro/sc22-benesh-repro

for method in lockstep ; do
    for scaling in weak ; do
        echo "making graphs for ${method}/${scaling}"
        cd ${REPRO_DIR}/results/${method}/${scaling}
        #${REPRO_DIR}/scripts/make_combo_graphs_adios.py > ${method}_${scaling}.csv
        sed -i 's/^dspaces,/adhoc_dspaces,/' timers.*csv
        sed -i 's/^dspaces,/adhoc_dspaces,/' traces.*csv
        sed -i 's/^adhoc,/adhoc_adios,/' traces.*csv
        sed -i 's/^adhoc,/adhoc_adios,/' timers.*csv
        ${REPRO_DIR}/scripts/make_combo_graphs_adios.py
    done
done
