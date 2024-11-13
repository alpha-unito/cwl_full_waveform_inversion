import argparse
import numpy as np

from utils import _load_object, _save_object


def main(args):
    matrix = _load_object(args.matrix)
    for i in range(args.nshards):
        _save_object(matrix[i, :], f"{args.prefix_out}.{i}.pickle")


if __name__ == "__main__":
    try:
        parser = argparse.ArgumentParser()
        parser.add_argument(
            "--nshards",
            help="Number of shards",
            type=int,
            required=True,
        )
        parser.add_argument(
            "--matrix",
            help="Path of numpy matrix pickle file",
            type=str,
            required=True,
        )
        parser.add_argument(
            "--prefix-out",
            help="Prefix outname files",
            type=str,
            required=True,
        )
        args = parser.parse_args()
        main(args)
    except KeyboardInterrupt:
        print("Interrupted!")
    pass
