import pandas as pd
from study_utils import OUTPUT_DIR

# loop through all the files in output. If they match input_end*.csv. load them

df = pd.read_csv(OUTPUT_DIR / "input_end.csv")
death_col = df["died_any"]

# output value counts including nan
counts = death_col.value_counts(dropna=False) 
counts = counts.round(-1)
counts.to_csv(OUTPUT_DIR / "died_any_counts.csv")
