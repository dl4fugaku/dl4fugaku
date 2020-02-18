import torch
import torch.nn
import torch.nn.functional as F
import numpy as np
from timeit import default_timer as timer

# TODO: consider calling functional directly
#result = F.conv2d(input, weight, bias=None, stride=1, padding=0, dilation=1, groups=1)

cnt_channels = 3
size_image = 512
cnt_filters = 32
size_kernel = 3
size_batch = 32
cnt_repeats = 10

conv1 = torch.nn.Conv2d(in_channels=cnt_channels,
                        out_channels=cnt_filters,
                        kernel_size=size_kernel,
                        stride=1,
                        padding=0,
                        dilation=1,
                        groups=1,
                        bias=True,
                        padding_mode='zeros')

# TODO: confirt channel ordering
np_random = np.ones((size_batch,
                     cnt_channels,
                     size_image,
                     size_image)).astype(np.float)

time_start = timer()
tensor_input = torch.Tensor(np_random)
time_end = timer()
for i in range(cnt_repeats):
    result = conv1(tensor_input)

print(f"time: {time_end - time_start}")