#!/bin/bash

. common.sh
rm -rf ${PREFIX} ${DOWNLOAD_PATH} ${VENV_PATH} slurm-*

PYTHON_DL_JOB_ID=$(sbatch ./download_python.sh) || exit 1
PYTHON_JOB_ID=$(sbatch -d afterok:${PYTHON_DL_JOB_ID##* } install_python.sh) || exit 2

TORCH_DL_JOB_ID=$(sbatch ./download_torch.sh) || exit 3
TORCH_JOB_ID=$(sbatch -d afterok:${TORCH_DL_JOB_ID##* } install_torch.sh) || exit 4

VISION_DL_JOB_ID=$(sbatch ./download_vision.sh) || exit 5
VISION_JOB_ID=$(sbatch -d afterok:${TORCH_JOB_ID##* },${VISION_DL_JOB_ID##* } install_vision.sh) || exit 6
