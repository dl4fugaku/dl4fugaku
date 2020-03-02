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
size_image = 224
cnt_filters = 64
size_kernel = 3
size_batch = 32
cnt_repeats = 4

conv1 = torch.nn.Conv2d(in_channels=cnt_channels,
                        out_channels=cnt_filters,
                        kernel_size=size_kernel,
                        stride=1,
                        padding=1,
                        dilation=1,
                        groups=1,
                        bias=True,
                        padding_mode='zeros')

# TODO: confirm channel ordering
np_random = np.ones((size_batch,
                     cnt_channels,
                     size_image,
                     size_image)).astype(np.float32)

tensor_input = torch.Tensor(np_random)
print(tensor_input.dtype)
print(conv1.weight.dtype)
#device = torch.device("cuda")
#torch.cuda.set_device(0)
#tensor_input = tensor_input.to(device)
#conv1.to(device)

time_start = timer()
for i in range(cnt_repeats):
    result = conv1(tensor_input)
#torch.cuda.synchronize()
time_end = timer()
print(result.shape)
elapsed_seconds = (time_end - time_start) / cnt_repeats
milliseconds =  elapsed_seconds * 1000
samples_per_second = size_batch / elapsed_seconds
print(f"time: {milliseconds:0.4} ms")
print(f"ips:  {samples_per_second:0.4} ms")
