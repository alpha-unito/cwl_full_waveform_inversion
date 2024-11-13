# Workflow

We wrote the workflow using CWL and executed using [StreamFlow](https://streamflow.di.unito.it/).
As said in the principal [README](../README.md), the workflow is based on the jupyter notebook available to the following [link](https://github.com/devitocodes/FWI_lectures/blob/main/lecture11/L11_numerical_implementations_of_fwi.ipynb).

# Applications

Following the notebook cells, we created self-contained Python applications. 
As the notebook, we used the Devito code library to improve the portability and performance of the applications.
The applications are in the `cwl/scrips` directory.

# Execution environment

In our experiment we used Python v3.10.12

```bash
    python -m venv venv
    pip install -r requirements.txt
    source venv/bin/activate
    streamflow run streamflow.yml
```

Before to reproduce the workflow execution, the user can custumize the [config](cwl/config.yml) file.
In particular:
- `nshots`: Number of shots to used to generate the gradient
- `nreceivers`: Number of receiver locations per shot 
- `fwi_iterations`: Number of outer FWI iterations
In the [notebook](https://github.com/devitocodes/FWI_lectures/blob/main/lecture11/L11_numerical_implementations_of_fwi.ipynb) these parameters are described in detail.

Other important hyperparameters are:
- `num_threads`: how many threads the `reduce` step can use.
- `nshards`: how many instance of the `compute residual` must be created.

