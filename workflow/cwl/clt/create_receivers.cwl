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
  model: 
    type: File
    inputBinding:
      position: 3
      prefix: --model 
  geometry: 
    type: File
    inputBinding:
      position: 4
      prefix: --geometry 

outputs:
  - id: grad
    type: File
    outputBinding:
      glob: "grad.pickle"
  - id: residual
    type: File
    outputBinding:
      glob: "residual.pickle"
  - id: d_obs
    type: File
    outputBinding:
      glob: "d_obs.pickle"
  - id: d_syn
    type: File
    outputBinding:
      glob: "d_syn.pickle"
