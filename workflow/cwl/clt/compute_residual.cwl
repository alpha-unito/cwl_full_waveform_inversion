cwlVersion: v1.2
class: CommandLineTool

requirements:
  InlineJavascriptRequirement: {}

baseCommand: [ "python" ]

inputs:
  script: 
    type: File
    inputBinding:
      position: 1
  geometry: 
    type: File
    inputBinding:
      position: 2
      prefix: --geometry 
  model: 
    type: File
    inputBinding:
      position: 3
      prefix: --model 
  solver:
    type: File 
    inputBinding:
      position: 4
      prefix: --solver
  d_obs:
    type: File 
    inputBinding:
      position: 5
      prefix: --d_obs
  residual:
    type: File 
    inputBinding:
      position: 6
      prefix: --residual
  d_syn:
    type: File 
    inputBinding:
      position: 7
      prefix: --d_syn
  vp_in:
    type: File 
    inputBinding:
      position: 9
      prefix: --vp_in
  src_location:
    type: File 
    inputBinding:
      position: 10
      prefix: --src_location

outputs:
  - id: residual # fixme InplaceUpdate
    type: File
    outputBinding:
      glob: "residual.pickle"
  - id: u0
    type: File
    outputBinding:
      glob: "u0.pickle"
