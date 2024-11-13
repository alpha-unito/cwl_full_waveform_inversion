import argparse

from devito import Function
from examples.seismic import Receiver

from utils import _load_object, _save_object


def main(args):
    model = _load_object(args.model)
    geometry = _load_object(args.geometry)

    _save_object(Function(name="grad", grid=model.grid), "grad")
    _save_object(
        Receiver(
            name="residual",
            grid=model.grid,
            time_range=geometry.time_axis,
            coordinates=geometry.rec_positions,
        ),
        "residual",
    )
    _save_object(
        Receiver(
            name="d_obs",
            grid=model.grid,
            time_range=geometry.time_axis,
            coordinates=geometry.rec_positions,
        ),
        "d_obs",
    )
    _save_object(
        Receiver(
            name="d_syn",
            grid=model.grid,
            time_range=geometry.time_axis,
            coordinates=geometry.rec_positions,
        ),
        "d_syn",
    )


if __name__ == "__main__":
    try:
        parser = argparse.ArgumentParser()
        parser.add_argument(
            "--model",
            help="Path of model pickle file",
            type=str,
            required=True,
        )
        parser.add_argument(
            "--geometry",
            help="Path of geometry pickle file",
            type=str,
            required=True,
        )
        args = parser.parse_args()
        main(args)
    except KeyboardInterrupt:
        print("Interrupted!")
    pass
