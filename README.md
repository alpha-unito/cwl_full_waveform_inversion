# CWL Full-Waveform Inversion

This repository contains a workflow which uses Python applications and the implementation of one of these Python application in C-code with CUDA and HIP.

This activity was done in collaboration with ENI company for the Innovation Grant `Cross-Platform Full-Waveform Inversion`.

The workflow is written using [Common Workflow Language](https://www.commonwl.org/) (CWL) and it is an implementation of a Full-Waveform Inversion problem.
The workflow is based on the jupyter notebook available to the following [link](https://github.com/devitocodes/FWI_lectures/blob/main/lecture11/L11_numerical_implementations_of_fwi.ipynb).
The workflow apps are developed in Python using the [Devito code](https://www.devitocodes.com/) library.
The [workflow](workflow/) directory has a [README](workflow/README.md) which describe the activity done, the Python scripts and CWL workflow.

Furthermore, we implemented a kernel from scratch in CUDA and HIP to evaluate the Devito performance.
The [kernels](kernels/) directory has a [README](kernels/README.md) which describe the activity done and the C codes.

# Contributors

Alberto Mulone <alberto.mulone@unito.it>  
Giulio Malenza <giulio.malenza@unito.it>   
Iacopo Colonnelli <iacopo.colonnelli@unito.it>   
Bienati Nicola <Nicola.Bienati@eni.com>   
Bortot Luca <Luca.Bortot@eni.com>   
Marco Aldinucci <marco.aldinucci@unito.it>