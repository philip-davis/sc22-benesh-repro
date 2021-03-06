#!/bin/bash -ex
#BSUB -P fus123
#BSUB -J benesh-sc22-repro
#BSUB -o benesh-sc22.o%J
#BSUB -W 40
#BSUB -nnodes 5
#BSUB -q batch

pwd
date
export FI_MR_CACHE_MAX_COUNT=0
export FI_OFI_RXM_USE_SRX=1
export APEX_TRACE_EVENT=1

export ABT_THREAD_STACKSIZE=2097152
export ABT_MEM_MAX_NUM_STACKS=8

export APEX_PROFILE_OUTPUT=1
export APEX_TIME_TOP_LEVEL_OS_THREADS=1
export APEX_UNTIED_TIMERS=1
export DSPACES_NUM_HANDLERS=32

export REPRO_DIR=/gpfs/alpine/scratch/pdavis/fus123/benesh-heateq/repro/sc22-benesh-repro

export BENESH_NA=verbs

module purge
module load DefApps
module load  gcc/9.1.0

source /gpfs/alpine/stf007/world-shared/containers/utils/requiredmpilibs.source

for method in async lockstep ; do
    for scaling in strong weak ; do
        for size in 64 ; do
            mkdir -p ${REPRO_DIR}/runtest/${method}/${scaling}
            cd ${REPRO_DIR}/runtest/${method}/${scaling}
            echo "doing $scaling $method test of size $size"
            ${REPRO_DIR}/scripts/run-test.sh $size $method $scaling
        done
    done
done
