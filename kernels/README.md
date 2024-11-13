# Kernels

## Overview
All the steps in the workflow utilize the Devito library in some capacity.
However, we focused on the most computationally intensive step, _reduce residuals_, for the Devito performance evaluation. This step performs gradient computation on all residuals.

In the Python application, the Devito library implements several solvers, such as the _AcousticWaveSolver_, which provides operators for seismic inversion problems. Specifically, the solver used in our application supplies the gradient operator. Devito generates the kernel in C code at runtime using a specific programming methodology and platform. Devito configures these options automatically by default, but users can modify them by setting environment variables.
The C code is compiled JIT, and both the source code and the compiled binaries are stored in a working directory that Devito creates on the machine. Finally, Python calls the function in the compiled code, passing the appropriate parameters (formatted as C data structures).

## Implementation
Looking to the code generated to Devito for the gradient, it can be divided in three sub-kernels.
The first two kernels update the velocities based on the finite-difference discretization of the wave equation, while the third kernel updates the velocity gradient.
By default, the open-source version of Devito supports OpenMP and OpenACC for GPU code generation. We used `DEVITO_LANGUAGE=OpenMP` and `DEVITO_PLATFORM=nvidiaX` to generate OpenMP code with Devito. The kernel is relatively small, and the auto-generated code does not exhibit inefficiencies, so further optimization is unnecessary. Starting from the OpenMP code, we developed CUDA and HIP versions to evaluate performance.
We decided to compile by hand the code and inject it inside Devito, instead of implement all the Devito interfaces necessary to get the _CudaCompiler_ and _HIPCompiler_ classes.
We intercept the function of DeVito when loading the compiled file, which has the `.so` extension used the path to our compiled CUDA or HIP code.
We manually compiled and integrated the code into Devito rather than implementing all the necessary Devito interfaces to use the CudaCompiler and HIPCompiler classes. We intercept Devito’s function that loads the compiled file (with the `.so` extension) and direct it to our compiled CUDA or HIP code path.

# Execution environment

Python v3.10.12  
Devito v4.8.11  
StreamFlow v0.2.0.dev11   

Experiments have been executed on a GraceHopper super chip running at the [HPC4AI](https://hpc4ai.unito.it/) available at the Department of Computer Science at the University of Torino. The GraceHopper machine has an NVIDIA Grace CPU with 72-core ArmV9 Neoverse V2 and 574GB of LPDDR5X Memory; each core has 64KB of I/D L1 Cache and 1MB of L2 Cache. 243 MB of system-level L3 cache is shared among the cores. The machine has a GPU GH200 with 96GB of HBM3 memory and NVLink 4, up to 900 GB/s of bandwidth. NVLink Chip-2-Chip (C2C) has a high bandwidth and memory coherent connection between CPU and GPU, providing up to 900GB/s of memory bandwidth. The system has a Linux Ubuntu 22.04 distribution, NVIDIA driver version 545.23.08, and GCC version 12.2.0. To compile CUDA code, we used `nvcc` compiler version 12.3. We used `hipcc` 5.7.3 for the HIP code and `nvc++` 24.3 for the OpenMP with GPU offloading. We compiled the codes specifying Standard C++14, and we used the optimization flag -O3. To offload OpenMP code with nvc++, we added -mp=gpu, and we specified the architecture with -gpu=cc90. To target the hopper GPU on the CUDA code, we add -arch=sm\_90. For the same reason, we add --gpu-architecture=sm\_90 to the hipcc compiler.
