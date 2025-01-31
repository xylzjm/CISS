# Licensed under the CC BY-NC 4.0 license (https://creativecommons.org/licenses/by-nc/4.0/)
#!/bin/bash
#
# Specify time limit.
#SBATCH --time=23:59:59
#
# Specify number of CPU cores.
#SBATCH -n 8
#
# Specify memory limit per CPU core.
#SBATCH --mem-per-cpu=8192
#
# Specify disk limit on local scratch.
#SBATCH --tmp=80000
#
# Specify number of required GPUs.
#SBATCH --gpus=1
#
# Specify required GPU memory.
#SBATCH --gres=gpumem:30g
#
# Specify file for logging standard output.
#SBATCH --output=../logs/exp_basic-csHR2acdcHR_ciss-slurm-05.o
#
# Specify file for logging standard error.
#SBATCH --error=../logs/exp_basic-csHR2acdcHR_ciss-slurm-05.e
#
# Specify open mode for log files.
#SBATCH --open-mode=append
#
# Specify jobname.
#SBATCH --job-name=exp_basic-csHR2acdcHR_ciss-slurm

/bin/echo Starting on: `date`

# Specify directories.
export TMPDIR="${TMPDIR}"
export SOURCE_DIR="/cluster/home/csakarid/code/SysCV/CISS"
export SOURCE_DATASET="cityscapes"
export TARGET_DATASET="acdc"
export DIR_SOURCE_DATASET="${TMPDIR}/${SOURCE_DATASET}"
export DIR_TARGET_DATASET="${TMPDIR}/${TARGET_DATASET}"
export TAR_SOURCE_DATASET="/cluster/work/cvl/csakarid/data/Cityscapes/Cityscapes.tar.gz"
export TAR_TARGET_DATASET="/cluster/work/cvl/csakarid/data/ACDC/ACDC_splits.tar.gz"

# Perform initialization operations for the experiment.
cd ${SOURCE_DIR}
source /cluster/home/csakarid/DISS/bin/activate
./experiments/scripts/initialization.sh
python tools/convert_datasets/cityscapes.py ${DIR_SOURCE_DATASET} --nproc 8

# Run the experiment.
python run_experiments.py --config configs/ciss/csHR2acdcHR_ciss.py

/bin/echo Finished on: `date`

