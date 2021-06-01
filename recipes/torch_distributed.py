#!/usr/bin/env python

import os

import torch
import torch.distributed as dist

if __name__ == "__main__":
    print(os.environ)
    is_nccl_socket_ifname_available = "NCCL_SOCKET_IFNAME" in os.environ
    print(f"Found var: {is_nccl_socket_ifname_available}")

    if dist.is_mpi_available():
        backend = "mpi"
    elif torch.cuda.is_available() and dist.is_nccl_available():
        backend = "nccl"
    elif dist.is_gloo_available():
        backend = "gloo"

    print(f"using backend: {backend}")
    dist.init_process_group(backend)
    print(f"RANK: {dist.get_rank()}, SIZE: {dist.get_world_size()}")
