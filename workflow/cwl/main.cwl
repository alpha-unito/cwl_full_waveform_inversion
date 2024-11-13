#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  SubworkflowFeatureRequirement: {}

$namespaces:
  cwltool: "http://commonwl.org/cwltool#"
  s: https://schema.org/

$schemas:
 - https://schema.org/version/latest/schemaorg-current-http.rdf

inputs:
  init_script: File
  receivers_script: File
  split_script: File
  compute_residual_script: File
  reduce_script: File
  update_script: File

  nshots: int 
  nreceivers: int 
  fwi_iterations: int

  num_threads: int
  nshards: int

outputs:
  objective:
    type: float[]
    outputSource: iterations/objective
  vp:
    type: File[]
    outputSource: iterations/vp

steps:
  create_model:
    in:
      script: init_script
      nshots: nshots 
      nreceivers: nreceivers 
    out:
      - id: model
      - id: solver
      - id: geometry
      - id: vp
      - id: source_locations
    run: clt/init.cwl

  iterations:
    in:
      nshots: nshots
      nshards: nshards
      update_script: update_script
      receivers_script: receivers_script
      split_script: split_script
      compute_residual_script: compute_residual_script
      reduce_script: reduce_script
      vp_in: create_model/vp
      model: create_model/model
      solver: create_model/solver
      geometry: create_model/geometry
      source_locations: create_model/source_locations
      iteration:
        default: 0
      fwi_iterations: fwi_iterations
      num_threads: num_threads
    out:
      [ objective, vp ]
    requirements:
      cwltool:Loop:
        loopWhen: $(inputs.iteration < inputs.fwi_iterations)
        loop:
          iteration:
            valueFrom: $(inputs.iteration + 1)
          vp_in: vp
        outputMethod: all
    run: iteration.cwl
