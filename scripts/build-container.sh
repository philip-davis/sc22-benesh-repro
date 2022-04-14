#BSUB -P fus123
#BSUB -W 0:30
#BSUB -nnodes 1
#BSUB -J singularity
#BSUB -o singularity.%J
#BSUB -e singularity.%J

module purge
module load DefApps
module load gcc/9.1.0
module -t list
singularity build --disable-cache sc22.sif docker://docker.io/philipdavis/sc22