#!/bin/bash
#
# Specify time limit.
#BSUB -W 47:59
#
# Specify number of CPU cores.
#BSUB -n 8
#
# Specify memory limit per CPU core.
#BSUB -R "rusage[mem=8192]"
#
# Specify disk limit on local scratch.
#BSUB -R "rusage[scratch=10000]"
#
# Specify number of required GPUs.
#BSUB -R "rusage[ngpus_excl_p=2]"
#
# Specify GPU type and number of required GPUs.
#BSUB -R "select[gpu_mtotal0>=20000]"
#
# Specify file for logging standard output.
#BSUB -o ../logs/exp_112-csHR2acdcHR_fda_diss_src_ceorig_inv-ablation_inv_weights-gpus2_distributed-02-%I.o
#
# Specify file for logging standard error.
#BSUB -e ../logs/exp_112-csHR2acdcHR_fda_diss_src_ceorig_inv-ablation_inv_weights-gpus2_distributed-02-%I.e
#
# Specify jobname and range of tasks for job array.
#BSUB -J exp_112-csHR2acdcHR_fda_diss_src_ceorig_inv-ablation_inv_weights-gpus2_distributed[4-8]

/bin/echo Starting on: `date`

# Experiment ID.
EXP_ID="112"

# Specify directories.
export TMPDIR="${TMPDIR}"
export SOURCE_DIR="/cluster/home/csakarid/code/SysCV/DISS"
export SOURCE_DATASET="cityscapes"
export TARGET_DATASET="acdc"
export DIR_SOURCE_DATASET="${TMPDIR}/${SOURCE_DATASET}"
export DIR_TARGET_DATASET="${TMPDIR}/${TARGET_DATASET}"
export TAR_SOURCE_DATASET="/cluster/work/cvl/csakarid/data/Cityscapes/Cityscapes.tar.gz"
export TAR_TARGET_DATASET="/cluster/work/cvl/csakarid/data/ACDC/ACDC_splits.tar.gz"

# Export task ID.
export LSB_JOBINDEX="${LSB_JOBINDEX}"

# Specify checkpoint to resume from.
export CHECKPOINT_RESUME=("/cluster/work/cvl/csakarid/results/DISS/local-exp"${EXP_ID}"/221101_1802_csHR2acdcHR_1024x1024_dacs_a999_fdthings_diss_src_ceorig_inv_rcs001-20_hrda1-512-01_daformer_sepaspp_sl_mitb5_poly10warm_s0_0b227/latest.pth" "/cluster/work/cvl/csakarid/results/DISS/local-exp"${EXP_ID}"/221101_2304_csHR2acdcHR_1024x1024_dacs_a999_fdthings_diss_src_ceorig_inv_rcs001-20_hrda1-512-01_daformer_sepaspp_sl_mitb5_poly10warm_s0_b206d/latest.pth" "/cluster/work/cvl/csakarid/results/DISS/local-exp"${EXP_ID}"/221102_0536_csHR2acdcHR_1024x1024_dacs_a999_fdthings_diss_src_ceorig_inv_rcs001-20_hrda1-512-01_daformer_sepaspp_sl_mitb5_poly10warm_s0_e9639/latest.pth" "/cluster/work/cvl/csakarid/results/DISS/local-exp"${EXP_ID}"/221102_0553_csHR2acdcHR_1024x1024_dacs_a999_fdthings_diss_src_ceorig_inv_rcs001-20_hrda1-512-01_daformer_sepaspp_sl_mitb5_poly10warm_s0_1722b/latest.pth" "/cluster/work/cvl/csakarid/results/DISS/local-exp"${EXP_ID}"/221102_0655_csHR2acdcHR_1024x1024_dacs_a999_fdthings_diss_src_ceorig_inv_rcs001-20_hrda1-512-01_daformer_sepaspp_sl_mitb5_poly10warm_s0_7a599/latest.pth")

# Perform initialization operations for the experiment.
cd ${SOURCE_DIR}
module load gcc/8.2.0 python_gpu/3.10.4 eth_proxy pigz
./experiments/scripts/initialization_torch_1_11.sh
source /cluster/home/csakarid/DISS_torch_1_9/bin/activate
python tools/convert_datasets/cityscapes.py ${DIR_SOURCE_DATASET} --nproc 8
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:256

# Calculate masterport for torch.distributed based on task ID.
MASTERPORT_BASE="29593"
MASTERPORT_THIS_TASK=$((${MASTERPORT_BASE}+${LSB_JOBINDEX}))

# Run the experiment.
python -m torch.distributed.launch --nproc_per_node=2 --nnodes=1 --node_rank=0 --master_port=${MASTERPORT_THIS_TASK} run_experiments.py --exp ${EXP_ID} --resume-from ${CHECKPOINT_RESUME[((${LSB_JOBINDEX}-4))]}

# Deactivate virtual environment for DISS.
deactivate

/bin/echo Finished on: `date`

