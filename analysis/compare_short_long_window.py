import pandas as pd
from pathlib import Path

OUTPUT_DIR = Path(__file__).parent.parent / "output"

long_window = pd.read_csv(OUTPUT_DIR / "input_long_window.csv.gz")
short_window = pd.read_csv(OUTPUT_DIR / "input_2021-01-01.csv.gz")


combined_data = []
# for each column, get the value counts
for col in long_window.columns:
    # if column ends with code
    if col.endswith("_code"):
        if col in short_window.columns:
            long_vc = long_window[col].value_counts()
            short_vc = short_window[col].value_counts()
            # combine and set column names to long and short
            combined = pd.concat([long_vc, short_vc], axis=1)
            combined.columns = ["long", "short"]
            combined_data.append(combined)

# combine all the dataframes
combined_data = pd.concat(combined_data, axis=0)
combined_data.to_csv(OUTPUT_DIR / "compare_short_long_window.csv")
            
  
