#!/bin/bash
rm -rf .local/ down slurm-*
./download_python.sh || exit 1
PYTHON_JOB_ID=$(sbatch install_python.sh) || exit 2
./download_torch.sh || exit 3
TORCH_JOB_ID=$(sbatch -d afterok:${PYTHON_JOB_ID##* } install_torch.sh) || exit 4
./download_vision.sh
VISION_JOB_ID=$(sbatch -d afterok:${TORCH_JOB_ID##* } install_vision.sh) || exit 5
