#!/usr/bin/env python

import torch.distributed as dist

if __name__ == "__main__":
    if dist.is_mpi_available():
        backend = "mpi"
    elif dist.is_nccl_available():  # and gpus
        backend = "nccl"
    elif dist.is_gloo_available():
        backend = "gloo"
    print(f"using backend: {backend}")
    dist.init_process_group(backend)
    print(f"RANK: {dist.get_rank()}, SIZE: {dist.get_world_size()}")
