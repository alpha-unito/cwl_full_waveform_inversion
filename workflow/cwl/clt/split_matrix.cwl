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
  nshards: 
    type: int
    inputBinding:
      position: 2
      prefix: --nshards 
  matrix: 
    type: File
    inputBinding:
      position: 3
      prefix: --matrix 
  prefix_out:
    type: string 
    inputBinding:
      position: 4
      prefix: --prefix-out

outputs:
  - id: rows
    type: File[]
    outputBinding:
      glob: "$(inputs.prefix_out)*.pickle"
