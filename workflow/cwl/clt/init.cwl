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
  nreceivers: 
    type: int
    inputBinding:
      position: 2
      prefix: --nreceivers 
  nshots: 
    type: int
    inputBinding:
      position: 3
      prefix: --nshots

outputs:
  - id: solver  
    type: File 
    outputBinding:
      glob: "solver.pickle"
  - id: geometry  
    type: File 
    outputBinding:
      glob: "geometry.pickle"
  - id: model  
    type: File 
    outputBinding:
      glob: "model.pickle"
  - id: vp
    type: File 
    outputBinding:
      glob: "vp.pickle"
  - id: source_locations
    type: File 
    outputBinding:
      glob: "source_locations.pickle"
