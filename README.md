# sc22-benesh-repro
Reproducibility Artifacts for "Benesh: Choreographic Coordination for In-situ Workflows"

The experiments for this paper were run on Summit at OLCF. We have created a container that runs on Summit that builds all depedencies as well as Benesh. The container is hosted on Docker Hub with the tag philipdavis/sc22, but it must be compiled into a Singularity container in order to run on Summit.

To perform the reproduction, the container must be generated, the experiments run and results generated.

The Dockerfiles used to create the container are found in the `containers/` directory of this repo. These can be used to modify the reproduction container following the instructions at:
https://docs.olcf.ornl.gov/software/containers_on_summit.html

It should not be necessary to modify or use the Dockerfiles, and further documentation on how to use them on Summit is not included here.

0. Clone this repository to somewhere on the Spectrum Scale file system (e.g. $MEMBERWORK)

'git clone https://github.com/philip-davis/sc22-benesh-repro.git`

1. Generating the Container

The container is hosted on Docker Hub, but must be converted to a Singularity container to run on Summit. This generally does not work on the login nodes of Summit (possibly due to cgroups limitations) so it has to be done inside a job. It takes a single node about 10-15 minutes. There is a job-script in the `scripts/` directory to do this, called `build-container.lsf`. In order to run the job script, the project must be changed to one that your user is a member of, but replacing `fus123` in the first line with your project ID.

This job script should be submitted with a working directory of `scripts/`, i.e.

```
cd scripts/
bsub build-container.lsf
```

This will create the sc22.sif container file in the `containers/` subdirectory.

2. Running the experiments.

There is a job script, `scripts/submit.lsf`, which runs all experiments from the paper. In order to run, the REPRO_DIR variable on line 23 needs to be set to the repo directory (wherever the repo was cloned - again, should be on the Summit Scale file system). Additionally, the second line of the script must be updated to the project being used for evaluation.

The experiments run will be a cross-product of {async, lockstep} method x {strong, weak} scaling x {64, 256, 1024, 4096} processes per component, with 5 trials each for a total of 16 different experiments each run 5 times. If run 'as is', the script will request 288 nodes for 2.5 hours. However, not all experiments use all 288 nodes, so some core hours will be wasted. To avoid this (and to verify functionality before committing to a larger run), lines 5, 6, and 35 can be adjusted to run the experiments in segments, if desired.

| Process Scale | Node Count |
| ----------- | ----------- |
| 64 | 5 |
| 256 | 18 |
| 1024 | 72 |
| 4096 | 288 | 
