import argparse
import json

from devito import norm

from utils import _load_object, _save_object


def main(args):
    objective = 0.0
    solver = _load_object(args.solver)
    grad = _load_object(args.grad)
    vp_in = _load_object(args.vp_in)
    for u0_path, residual_path in zip(args.u0, args.residual):
        residual = _load_object(residual_path)
        u0 = _load_object(u0_path)
        objective += 0.5 * norm(residual) ** 2
        solver.gradient(rec=residual, u=u0, vp=vp_in, grad=grad)

    with open("objective.json", "w") as fd:
        json.dump({"objective": float(objective)}, fd)
    _save_object(grad, "grad")


if __name__ == "__main__":
    try:
        parser = argparse.ArgumentParser()
        for option in ["residual", "u0"]:
            parser.add_argument(
                f"--{option}",
                action="append",
                help=f"Input path of a {option} pickle file",
                type=str,
                required=True,
            )
        for option in ["solver", "grad", "vp_in"]:
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
