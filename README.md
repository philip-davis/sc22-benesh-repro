# sc22-benesh-repro
Reproducibility Artifacts for "Benesh: Choreographic Coordination for In-situ Workflows"

To perform the reproduction, the container must be generated, the experiments run and results generated.

1. Generating the Container

The container is hosted on Docker Hub, but must be converted to a Singularity container to run on Summit. This generally does not work on the login nodes of Summit (possibly due to cgroups limitations) so it has to be done inside a job. It takes a single node about 10-15 minutes. There is a job-script in the `scripts/` directory to do this, called `build-container.lsf`. This should be submitted with a working directory of scripts
