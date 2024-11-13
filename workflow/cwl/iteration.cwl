#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow
$namespaces:
  sf: "https://streamflow.org/cwl#"

requirements:
  ScatterFeatureRequirement: { }

inputs:
  receivers_script: File
  split_script: File
  compute_residual_script: File
  reduce_script: File
  update_script: File
  
  model: File
  geometry: File
  solver: File
  vp_in: File

  nshots: int
  source_locations: File

  iteration: int
  fwi_iterations: int

  num_threads: int
  nshards: int


outputs:
  - id: objective
    type: float
    outputSource: reduce_residuals/objective
  - id: vp
    type: File
    outputSource: update_with_box/vp

steps:
  init_residuals:
    in:
      script: receivers_script
      model: model
      geometry: geometry
    out:
      [ grad, residual, d_obs, d_syn ]
    run: clt/create_receivers.cwl

  split_locations:
    in:
      script: split_script
      nshards: nshards
      matrix: source_locations
      prefix_out:
        default: "source_location"
    out:
      [ rows ]
    run: clt/split_matrix.cwl

  compute_residual:
    in:
      script: compute_residual_script
      geometry: geometry 
      model: model
      solver: solver
      residual: init_residuals/residual
      d_syn: init_residuals/d_syn
      d_obs: init_residuals/d_obs
      vp_in: vp_in
      src_location: split_locations/rows
    out:
      [ residual, u0 ]
    run: clt/compute_residual.cwl
    scatter: src_location

  reduce_residuals:
    in: 
      script: reduce_script
      residuals: compute_residual/residual
      grad: init_residuals/grad
      vp_in: vp_in
      solver: solver
      u0: compute_residual/u0
      num_threads: num_threads
    out:
      [ objective, grad ]
    run: clt/reduce.cwl

  update_with_box:
    in:
      script: update_script
      vp: vp_in
      direction: reduce_residuals/grad
    out:
      [ vp ]
    run: clt/update_with_box.cwl
