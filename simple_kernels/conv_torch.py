import torch
import torch.nn
import torch.nn.functional as F
import torch.backends.mkldnn
import numpy as np
from timeit import default_timer as timer

# TODO: consider calling functional directly
#result = F.conv2d(input, weight, bias=None, stride=1, padding=0, dilation=1, groups=1)
torch.backends.mkldnn.enabled = False

cnt_channels = 3
size_image = 456
cnt_filters = 32
size_kernel = 3
size_batch = 32
cnt_repeats = 1

conv1 = torch.nn.Conv2d(in_channels=cnt_channels,
                        out_channels=cnt_filters,
                        kernel_size=size_kernel,
                        stride=1,
                        padding=0,
                        dilation=1,
                        groups=1,
                        bias=True,
                        padding_mode='zeros')

# TODO: confirm channel ordering
np_random = np.ones((size_batch,
                     cnt_channels,
                     size_image,
                     size_image)).astype(np.float)

tensor_input = torch.Tensor(np_random)
time_start = timer()
for i in range(cnt_repeats):
    result = conv1(tensor_input)
time_end = timer()

print(f"time: {time_end - time_start}")
