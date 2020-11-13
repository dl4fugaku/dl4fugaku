#!/bin/bash

. activate.sh

rm -rf ${PREFIX} ${DOWNLOAD_PATH} ${VENV_PATH} slurm-*

PYTHON_JOB_ID=$(sbatch install_python.sh) || exit 2

TORCH_JOB_ID=$(sbatch -d afterok:${PYTHON_JOB_ID##* } install_torch.sh) || exit 4

VISION_JOB_ID=$(sbatch -d afterok:${TORCH_JOB_ID##* } install_vision.sh) || exit 6

TRANSFORMER_JOB_ID=$(sbatch -d afterok:${VISION_JOB_ID##* } install_transformers.sh) || exit 8

