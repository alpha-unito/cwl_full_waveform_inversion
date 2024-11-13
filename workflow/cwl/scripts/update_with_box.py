import argparse

from devito import Eq, Operator
from devito import mmax
from sympy import Min, Max

from utils import _load_object, _save_object


def update_with_box(vp, alpha, dm, vmin=2.0, vmax=3.5):
    """
    Apply gradient update in-place to vp with box constraint

    Notes:
    ------
    For more advanced algorithm, one will need to gather the non-distributed
    velocity array to apply constrains and such.
    """
    update = vp + alpha * dm
    update_eq = Eq(vp, Max(Min(update, vmax), vmin))
    Operator(update_eq)()


def main(args):
    direction = _load_object(args.direction)
    vp = _load_object(args.vp)
    alpha = 0.05 / mmax(direction)

    # Update the model estimate and enforce minimum/maximum values
    update_with_box(vp, alpha, direction)

    _save_object(vp, "vp")


if __name__ == "__main__":
    try:
        parser = argparse.ArgumentParser()
        parser.add_argument(
            "--vp",
            help="Path of vp pickle file",
            type=str,
            required=True,
        )
        parser.add_argument(
            "--direction",
            help="Path of direction pickle file",
            type=str,
            required=True,
        )
        args = parser.parse_args()
        main(args)
    except KeyboardInterrupt:
        print("Interrupted!")
    pass
