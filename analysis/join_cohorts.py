from pathlib import Path
import argparse
import re
import pandas as pd

def parse_args():
    parser = argparse.ArgumentParser()
    # input files is Path 
    parser.add_argument('--input-dir', type=Path, required=True)
    parser.add_argument('--output-dir', type=Path, required=True)
    return parser.parse_args()

def match_input_files(file: str) -> bool:
    """Checks if file name has format outputted by cohort extractor"""
    pattern = r"^input_v2_([a-zA-Z]+\_)*20\d\d-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])\.csv.gz"
    return True if re.match(pattern, file) else False

def get_date_input_file(file: str) -> str:
    """Gets the date in format YYYY-MM-DD from input file name string
    """
    # check format
    if not match_input_files(file):
        raise Exception("Not valid input file format")

    else:
        date = re.search(r"(\d{4}-\d{2}-\d{2})", file)
        return date.group(1)


def main():
    args = parse_args()
    output_dir = args.output_dir
    input_dir = args.input_dir

    if not output_dir.exists():
        output_dir.mkdir(parents=True, exist_ok=True)

    # read in all the input files that match the glob pattern
    # and concatenate them into a single dataframe (by joining on patient_id) for each index date
    # write the output to a csv file in the output directory
    
    files = {}

    for file in input_dir.iterdir():
    
        if match_input_files(file.name):
            date = get_date_input_file(file.name)
          
            # if date key doesn't exist in dict, create it - empyt list
            
            if date not in files:
                files[date] = []
            
            else:
                files[date].append(file)

    for date, file_list in files.items():
       
        for i, file in enumerate(file_list):
            if i == 0:
                df = pd.read_csv(file)
            else:
                # join on patient_id - remove duplicate columns
                df = df.join(pd.read_csv(file).set_index(['patient_id', 'flucats_template', 'flucats_template_date', 'sex', 'practice']), on=['patient_id', 'flucats_template', 'flucats_template_date', 'sex', 'practice'], how='left', lsuffix='_left', rsuffix='_right')
                
        
        df.to_csv(output_dir / f"input_v2_{date}.csv.gz", index=False)




if __name__ == '__main__':
    main()