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
  vp: 
    type: File
    inputBinding:
      position: 2
      prefix: --vp 
  direction: 
    type: File
    inputBinding:
      position: 3
      prefix: --direction 

outputs:
  - id: vp # fixme InplaceUpdate
    type: File
    outputBinding:
      glob: "vp.pickle"

