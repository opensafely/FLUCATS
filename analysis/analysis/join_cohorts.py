from pathlib import Path
import argparse
import re
import pandas as pd


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input-dir", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    return parser.parse_args()


def match_input_files(file: str) -> bool:
    pattern = (
        r"^input_([a-zA-Z]+\_)*20\d\d-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])\.csv"
    )
    return bool(re.match(pattern, file))


def get_date_input_file(file: str) -> str:
    """
    Gets the date in format YYYY-MM-DD from input file name string
    """
    
    if not match_input_files(file):
        raise Exception("Not valid input file format")
    date = re.search(r"(\d{4}-\d{2}-\d{2})", file)
    return date.group(1)


def create_directory_if_not_exists(directory: Path):
    if not directory.exists():
        directory.mkdir(parents=True, exist_ok=True)


def create_files_dictionary(input_dir: Path):
    files = {}
    for file in input_dir.iterdir():
        if match_input_files(file.name):
            date = get_date_input_file(file.name)
            files.setdefault(date, []).append(file)
    return files


def read_and_join_files(file_list):
    join_columns = [
        "patient_id",
        "flucats_template",
        "flucats_template_date",
        "sex",
        "practice",
    ]
    for i, file in enumerate(file_list):
        file_data = pd.read_csv(file).set_index(join_columns)
        if i == 0:
            df = file_data
        else:
            df = df.join(file_data, on=join_columns, how="outer")

    return df.reset_index()


def main():
    args = parse_args()
    output_dir = args.output_dir
    input_dir = args.input_dir

    create_directory_if_not_exists(output_dir)

    files = create_files_dictionary(input_dir)

    for date, file_list in files.items():
        df = read_and_join_files(file_list)
        df.to_csv(output_dir / f"input_{date}.csv", index=False)


if __name__ == "__main__":
    main()
