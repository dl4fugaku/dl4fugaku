#!/usr/bin/env python

import torch.distributed as dist

if __name__ == "__main__":
    available = dist.is_mpi_available()
    print(f"mpi available: {available}")
    backend = "mpi" if dist.is_mpi_available() else "nccl"
    dist.init_process_group(backend)
    print(f"RANK: {dist.get_rank()}, SIZE: {dist.get_world_size()}")
