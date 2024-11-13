import argparse
import numpy as np

from devito import configuration
from utils import _save_object


def main(args):
    configuration["log-level"] = (
        "WARNING"  # This added simply to reduce clutter in the output
    )

    ##############################
    nshots = args.nshots  # Number of shots to used to generate the gradient
    nreceivers = args.nreceivers  # Number of receiver locations per shot

    ##############################
    from examples.seismic import demo_model, plot_velocity, plot_perturbation

    # Define true and initial model
    shape = (201, 201)  # Number of grid point (nx, nz)
    spacing = (10.0, 10.0)  # Grid spacing in m. The domain size is now 1km by 1km
    origin = (0.0, 0.0)  # Need origin to define relative source and receiver locations

    model = demo_model(
        "circle-isotropic",
        vp_circle=3.0,
        vp_background=2.5,
        origin=origin,
        shape=shape,
        spacing=spacing,
        nbl=40,
    )

    model0 = demo_model(
        "circle-isotropic",
        vp_circle=2.5,
        vp_background=2.5,
        origin=origin,
        shape=shape,
        spacing=spacing,
        nbl=40,
        grid=model.grid,
    )

    # plot_velocity(model)
    # plot_velocity(model0)

    ##############################
    # Define acquisition geometry: source
    from examples.seismic import AcquisitionGeometry

    t0 = 0.0
    tn = 1000.0
    f0 = 0.010
    # Position the source:
    src_coordinates = np.empty((1, 2))
    src_coordinates[0, 1] = np.array(model.domain_size[1]) * 0.5
    src_coordinates[0, 0] = 20.0

    # Define acquisition geometry: receivers

    # Initialize receivers for synthetic and imaging data
    rec_coordinates = np.empty((nreceivers, 2))
    rec_coordinates[:, 1] = np.linspace(0, model.domain_size[0], num=nreceivers)
    rec_coordinates[:, 0] = 980.0

    # Geometry

    geometry = AcquisitionGeometry(
        model, rec_coordinates, src_coordinates, t0, tn, f0=f0, src_type="Ricker"
    )
    # We can plot the time signature to see the wavelet
    # geometry.src.show()

    ##############################

    # Plot acquisition geometry
    # plot_velocity(
    #     model, source=geometry.src_positions, receiver=geometry.rec_positions[::4, :]
    # )

    ##############################

    # Compute synthetic data with forward operator
    from examples.seismic.acoustic import AcousticWaveSolver

    solver = AcousticWaveSolver(model, geometry, space_order=4)
    true_d, _, _ = solver.forward(vp=model.vp)

    ##############################

    # Compute initial data with forward operator
    smooth_d, _, _ = solver.forward(vp=model0.vp)

    ##############################

    from examples.seismic import plot_shotrecord

    # Plot shot record for true and smooth velocity model and the difference
    # plot_shotrecord(true_d.data, model, t0, tn)
    # plot_shotrecord(smooth_d.data, model, t0, tn)
    # plot_shotrecord(smooth_d.data - true_d.data, model, t0, tn)

    ##############################

    # Prepare the varying source locations
    source_locations = np.empty((nshots, 2), dtype=np.float32)
    source_locations[:, 0] = 30.0
    source_locations[:, 1] = np.linspace(0.0, 1000, num=nshots)

    # plot_velocity(model, source=source_locations)

    _save_object(solver, "solver")
    _save_object(model, "model")
    _save_object(geometry, "geometry")
    _save_object(model0.vp, "vp")
    _save_object(source_locations, "source_locations")


if __name__ == "__main__":
    try:
        parser = argparse.ArgumentParser()
        parser.add_argument(
            "--nshots",
            help=f"Number of shots",
            type=int,
            required=True,
        )
        parser.add_argument(
            "--nreceivers",
            help=f"Number of receivers",
            type=int,
            required=True,
        )
        args = parser.parse_args()
        main(args)
    except KeyboardInterrupt:
        print("Interrupted!")
    pass
