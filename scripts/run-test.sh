#!/bin/bash -x

nprocs=$1
xprocdim=1
yprocdim=$nprocs
while [ "$xprocdim" -lt "$yprocdim" ] ; do
    xprocdim=$(($xprocdim * 2));
    yprocdim=$(($yprocdim / 2));
done
nserv=$(($nprocs / 128))
if [ "$nserv" == 0 ] ; then
    nserv=1
fi

method=$2
if [ "$method" == "lockstep" ] ; then
    adhoc_exe=/benesh/benesh/build/bin/heateq_adhoc
else
    adhoc_exe=/benesh/benesh/build/bin/heateq_adhoc_async
fi

scaling=$3
if [ "$scaling" == "strong" ] ; then
    xdim=32768
    ydim=32768
    xconfdim=8192
else
    xdim=$(($xprocdim * 1024))
    xconfdim=$(($xprocdim * 256))
    ydim=$(($yprocdim * 1024))
fi

sif_file=${REPRO_DIR}/containers/sc22.sif

mkdir -p $nprocs
cp ${REPRO_DIR}/conf/heateq2d_${method}.xc $nprocs/
cd $nprocs

rm -rf conf.ds *.ekt *.log
## Create dataspaces configuration file
echo "## Config file for DataSpaces
ndim = 2
dims = ${xdim}, ${xconfdim}
max_versions = 10
num_apps = 2
hash_version = 2
" > dataspaces.conf
ntrials=5

for iter in `seq 1 ${ntrials}` ; do
    ## Create dataspaces configuration file
    echo "## Config file for DataSpaces
    ndim = 2
    dims = 32768, 8192
    max_versions = 10
    num_apps = 2
    hash_version = 2
    " > dataspaces.conf
    echo "starting benesh iteration ${iter}"
    rm -rf conf.ds *.ekt
    mkdir dspaces.b.${iter}
    export TRACEDIR=dspaces.b.${iter}
    export APEX_OUTPUT_FILE_PATH=${TRACEDIR}
    export APEX_OTF2_ARCHIVE_PATH=${TRACEDIR}
    echo -n $nserv -a 1 -c 32 -r 1 -e prepended -o server-b.${iter}.out.%j -k  server-b.err.${iter}.%j singularity exec --bind $MPI_ROOT:$MPI_ROOT,/autofs/nccs-svm1_home1,/autofs/nccs-svm1_home1:/ccs/home,$(pwd):/jobdir --pwd /jobdir ${sif_file} /install/dspaces/bin/dspaces_server verbs &
    touch conf.ds
    while [ ! -f conf.ds ]; do
        sleep 1s
    done
    echo "started server"
    mkdir bprof-left.${iter}
    export TRACEDIR=bprof-left.${iter}
    export APEX_OUTPUT_FILE_PATH=${TRACEDIR}
    export APEX_OTF2_ARCHIVE_PATH=${TRACEDIR}
    export IBRUN_TASKS_PER_NODE=32
    startproc=$(($IBRUN_TASKS_PER_NODE * $nserv))
    echo -n $nprocs -a 1 -c 1 -r 32 -e prepended -o left-b.${iter}.out.%j -k left-b.err.${iter}.%j singularity exec --bind $MPI_ROOT:$MPI_ROOT,/autofs/nccs-svm1_home1,/autofs/nccs-svm1_home1:/ccs/home,$(pwd):/jobdir --pwd /jobdir ${sif_file} /benesh/benesh/build/bin/heateq_benesh $xprocdim $yprocdim $xdim $ydim heat1 &
    echo "started left side"
    leftproc=$!
    mkdir bprof-right.${iter}
    export TRACEDIR=bprof-right.${iter}
    export APEX_OUTPUT_FILE_PATH=bprof-right.${iter}
    export APEX_OTF2_ARCHIVE_PATH=${TRACEDIR}
    export IBRUN_TASKS_PER_NODE=32
    startproc=$(($nprocs + ($IBRUN_TASKS_PER_NODE * $nserv)))
    echo -n $nprocs -a 1 -c 1 -r 32 -e prepended -o right-b.${iter}.out.%j -k right-b.err.${iter}.%j singularity exec --bind $MPI_ROOT:$MPI_ROOT,/autofs/nccs-svm1_home1,/autofs/nccs-svm1_home1:/ccs/home,$(pwd):/jobdir --pwd /jobdir ${sif_file} /benesh/benesh/build/bin/heateq_benesh $xprocdim $yprocdim $xdim $ydim heat2
    echo "finished right side, waiting on left"
    wait $leftproc
    echo "benesh iteration ${iter} complete"
#done

#for iter in `seq 1 ${ntrials}` ; do
    ## Create dataspaces configuration file
    echo "## Config file for DataSpaces
    ndim = 
    dims = ${xconfdim}, ${xdim}
    max_versions = 10
    num_apps = 2
    hash_version = 2
    " > dataspaces.conf
    echo "starting adhoc iteration ${iter}"
    rm -rf conf.ds *.ekt
    mkdir dspaces.a.${iter}
    export TRACEDIR=dspaces.a.${iter}
    export APEX_OUTPUT_FILE_PATH=${TRACEDIR}
    export APEX_OTF2_ARCHIVE_PATH=${TRACEDIR}
    export IBRUN_TASKS_PER_NODE=1
    echo -n $nserv -a 1 -c 32 -r 1 -e prepended -o server-a.${iter}.out.%j -k  server-a.err.${iter}.%j singularity exec --bind $MPI_ROOT:$MPI_ROOT,/autofs/nccs-svm1_home1,/autofs/nccs-svm1_home1:/ccs/home,$(pwd):/jobdir --pwd /jobdir ${sif_file} /install/dspaces/bin/dspaces_server verbs &
    touch conf.ds
    while [ ! -f conf.ds ]; do
        sleep 1s
    done
    echo "started server"
    mkdir aprof-left.${iter}
    export TRACEDIR=aprof-left.${iter}
    export APEX_OUTPUT_FILE_PATH=aprof-left.${iter}
    export APEX_OTF2_ARCHIVE_PATH=${TRACEDIR}
    export IBRUN_TASKS_PER_NODE=32
    startproc=$(($IBRUN_TASKS_PER_NODE * $nserv))
    echo -n $nprocs -a 1 -c 1 -r 32 -e prepended -o left-a.${iter}.out.%j -k left-a.${iter}.%j singularity exec --bind $MPI_ROOT:$MPI_ROOT,/autofs/nccs-svm1_home1,/autofs/nccs-svm1_home1:/ccs/home,$(pwd):/jobdir --pwd /jobdir ${sif_file} ${adhoc_exe} $xprocdim $yprocdim 0 0 0.625 1.09375 ${xdim} ${ydim} 0.46875 1.09375
    echo "started left side"
    leftproc=$!
    mkdir aprof-right.${iter}
    export TRACEDIR=aprof-right.${iter}
    export APEX_OUTPUT_FILE_PATH=aprof-right.${iter}
    export APEX_OTF2_ARCHIVE_PATH=${TRACEDIR}
    export IBRUN_TASKS_PER_NODE=32
    startproc=$(($nprocs + ($IBRUN_TASKS_PER_NODE * $nserv)))
    echo -n $nprocs -a 1 -c 1 -r 32 -e prepended -o right-a.${iter}.out.%j -k right-a.${iter}.%j singularity exec --bind $MPI_ROOT:$MPI_ROOT,/autofs/nccs-svm1_home1,/autofs/nccs-svm1_home1:/ccs/home,$(pwd):/jobdir --pwd /jobdir ${sif_file} ${adhoc_exe} $xprocdim $yprocdim 0.46875 0 1.09375 1.09375 ${xdim} ${ydim} 0 0.625
    echo "finished right side, waiting on left"
    wait $leftproc
    echo "adhoc iteration ${iter} complete"
done

cd ..
