import argparse
import numpy as np

from devito import Eq, Operator

from utils import _load_object, _save_object


# Computes the residual between observed and synthetic data into the residual
def compute_residual(residual, dobs, dsyn):
    if residual.grid.distributor.is_parallel:
        # If we run with MPI, we have to compute the residual via an operator
        # First make sure we can take the difference and that receivers are at the
        # same position
        assert np.allclose(dobs.coordinates.data[:], dsyn.coordinates.data)
        assert np.allclose(residual.coordinates.data[:], dsyn.coordinates.data)
        # Create a difference operator
        diff_eq = Eq(
            residual,
            dsyn.subs({dsyn.dimensions[-1]: residual.dimensions[-1]})
            - dobs.subs({dobs.dimensions[-1]: residual.dimensions[-1]}),
        )
        Operator(diff_eq)()
    else:
        # A simple data difference is enough in serial
        residual.data[:] = dsyn.data[:] - dobs.data[:]
    return residual


def main(args):
    geometry = _load_object(args.geometry)
    model = _load_object(args.model)
    solver = _load_object(args.solver)
    d_obs = _load_object(args.d_obs)
    residual = _load_object(args.residual)
    d_syn = _load_object(args.d_syn)
    vp_in = _load_object(args.vp_in)

    # Update source location
    geometry.src_positions[0, :] = _load_object(args.src_location)
    # Generate synthetic data from true model
    _, _, _ = solver.forward(vp=model.vp, rec=d_obs)

    # Compute smooth data and full forward wavefield u0
    _, u0, _ = solver.forward(vp=vp_in, save=True, rec=d_syn)

    # Compute gradient from data residual and update objective function
    compute_residual(residual, d_obs, d_syn)

    _save_object(u0, "u0")
    _save_object(residual, "residual")


if __name__ == "__main__":
    try:
        parser = argparse.ArgumentParser()
        for option in [
            "geometry",
            "model",
            "solver",
            "d_obs",
            "residual",
            "d_syn",
            "vp_in",
            "src_location",
        ]:
            parser.add_argument(
                f"--{option}",
                help=f"Path of `{option}` pickle file",
                type=str,
                required=True,
            )

        args = parser.parse_args()
        main(args)
    except KeyboardInterrupt:
        print("Interrupted!")
    pass
