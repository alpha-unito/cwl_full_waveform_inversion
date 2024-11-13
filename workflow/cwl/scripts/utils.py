import os
import pickle
from pathlib import Path


def _load_object(path):
    if not os.path.exists(path):
        raise Exception(f"File {path} does not exist")
    with open(path, "rb") as fd:
        return pickle.load(fd)


def _save_object(obj, name):
    with open(Path(name).with_suffix(".pickle"), "wb") as fd:
        pickle.dump(obj, fd)
