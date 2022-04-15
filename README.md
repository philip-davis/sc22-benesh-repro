# sc22-benesh-repro
Reproducibility Artifacts for "Benesh: Choreographic Coordination for In-situ Workflows"

The experiments for this paper were run on Summit at OLCF. We have created a container that runs on Summit that builds all depedencies as well as Benesh. The container is hosted on Docker Hub with the tag philipdavis/sc22, but it must be compiled into a Singularity container in order to run on Summit.

To perform the reproduction, the container must be generated, the experiments run and results generated.

The Dockerfiles used to create the container are found in the `containers/` directory of this repo. These can be used to modify the reproduction container following the instructions at:
https://docs.olcf.ornl.gov/software/containers_on_summit.html

It should not be necessary to modify or use the Dockerfiles, and further documentation on how to use them on Summit is not included here.

### 0. Clone this repository 
It must be cloned to somewhere on the Spectrum Scale file system (e.g. within $MEMBERWORK)

`git clone https://github.com/philip-davis/sc22-benesh-repro.git`

### 1. Generate the container

The container is hosted on Docker Hub, but must be converted to a Singularity container to run on Summit. This generally does not work on the login nodes of Summit (possibly due to cgroups limitations) so it has to be done inside a job. It takes a single node about 10-15 minutes. There is a job-script in the `scripts/` directory to do this, called `build-container.lsf`. In order to run the job script, the project must be changed to one that your user is a member of, but replacing `fus123` in the first line with your project ID.

This job script should be submitted with a working directory of `scripts/`, i.e.

```
cd scripts/
bsub build-container.lsf
```

This will create the sc22.sif container file in the `containers/` subdirectory.

### 2. Run the experiments.

There is a job script, `scripts/submit.lsf`, which runs all experiments from the paper. In order to run, the REPRO_DIR variable on line 23 needs to be set to the repo directory (wherever the repo was cloned - again, should be on the Summit Scale file system). Additionally, the second line of the script must be updated to the project being used for evaluation. The script can be run from the repo root with:

`bsub scripts/submit.lsf`

The experiments run will be a cross-product of {async, lockstep} method x {strong, weak} scaling x {64, 256, 1024, 4096} processes per component, with 5 trials each for a total of 16 different experiments each run 5 times. If run 'as is', the script will request 288 nodes for 2.5 hours. However, not all experiments will use all 288 nodes, so some core hours will be wasted. To avoid this (or to verify functionality before committing to a larger run), lines 5, 6, and 35 can be adjusted to run the experiments in segments, if desired.

The number of nodes requested on line 6 should be sufficient for the largest scale being run on line 35. Below is a table of the number of nodes required to run each process scale. A reasonable approach might be to start with teh 64 process scale to verify functionality, then do the 256 and 1024 process scale together, then do the 4096 process scale.

| Process Scale | Node Count |
| ----------- | ----------- |
| 64 | 5 |
| 256 | 18 |
| 1024 | 72 |
| 4096 | 288 | 

The result of the job script will be a directory tree under `run/`, containing the results of the experiments. Each set of trials will be in the directory `run/<method>/<scaling_type>/<process scale>`. There will be a separate directory with APEX timing data for each component.

### Generate results
This requires two steps. The first is to collect results from the output of the experiments. This is done using the `scripts/collect_results.sh` script. This should be run on the login node of Summit (not as a job script) Line 8 of the script needs to be updated with the root directory of the repo. The script should be run from the root directory of the repo:

`scripts/collect_results.sh`

The script may take a significant amount of time to run, as it must unzip a trace file for each rank of each trial of each experiment. The script's output to the terminal is just for status monitoring - it can be disregarded. The script creates and populates a `results/` directory, that contins csvs of the traces and timers of each component of each experiment.

These csvs are input for the second step, which is to create data points and graphs. 
