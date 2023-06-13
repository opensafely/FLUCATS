import os
import pandas as pd
from pathlib import Path

INPUT_DIRECTORY = "output/joined/full"
OUTPUT_FILE = "output/joined/full/input_all.csv"


def chunk_and_filter(file_path, date):
    """
    Read file in chunks and filter for flucats_template == 1
    """
    filtered = []
    for chunk in pd.read_csv(file_path, chunksize=100000):
        chunk_filtered = chunk[chunk["flucats_template"] == 1]
        chunk_filtered["date"] = date
        filtered.append(chunk_filtered)
    return pd.concat(filtered)


def get_file_paths(directory):
    """
    Get all file paths in directory that match input files
    """
    return (
        (file, get_date_input_file(file.name))
        for file in Path(directory).iterdir()
        if match_input_files(file.name)
    )


def main():
    file_paths = get_file_paths(INPUT_DIRECTORY)
    combined_df = pd.concat(
        [chunk_and_filter(file_path, date) for file_path, date in file_paths],
        ignore_index=True,
    )
    combined_df.to_csv(OUTPUT_FILE, index=False)


if __name__ == "__main__":
    main()
