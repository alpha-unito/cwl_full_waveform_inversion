cwlVersion: v1.2
class: CommandLineTool

requirements:
  InlineJavascriptRequirement: {}
  EnvVarRequirement:
    envDef:
      OMP_NUM_THREADS: $(inputs.num_threads)
      ### Advanced Devito options
      # DEVITO_LANGUAGE: "openmp"
      # DEVITO_PLATFORM: "nvidiaX"

baseCommand: [ "python" ]

inputs:
  script: 
    type: File
    inputBinding:
      position: 1
  solver: 
    type: File
    inputBinding:
      position: 2
      prefix: --solver 
  u0: 
    type: 
      type: array
      items: File 
      inputBinding:
        prefix: --u0
        position: 3
  residuals:
    type: 
      type: array
      items: File 
      inputBinding:
        prefix: --residual
        position: 4
  grad:
    type: File 
    inputBinding:
      position: 5 
      prefix: --grad 
  vp_in:
    type: File 
    inputBinding:
      position: 6
      prefix: --vp_in
  num_threads:
    type: int 

outputs:
  - id: objective
    type: float
    outputBinding:
      loadContents: true
      glob: "objective.json"
      outputEval: $(JSON.parse(self[0].contents).objective)
  - id: grad  # fixme InplaceUpdate
    type: File 
    outputBinding:
      glob: "grad.pickle"

