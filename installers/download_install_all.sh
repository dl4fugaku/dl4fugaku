#!/bin/bash

. activate.sh

rm -rf ${PREFIX} ${DOWNLOAD_PATH} ${VENV_PATH} slurm-*

JOB_ID=$(sbatch install_python.sh) || exit 2

JOB_ID=$(sbatch -d afterok:${JOB_ID##* } install_torch.sh) || exit 4

JOB_ID=$(sbatch -d afterok:${JOB_ID##* } install_vision.sh) || exit 6

JOB_ID=$(sbatch -d afterok:${JOB_ID##* } install_rust.sh) || exit 8

JOB_ID=$(sbatch -d afterok:${JOB_ID##* } install_transformers.sh) || exit 10

