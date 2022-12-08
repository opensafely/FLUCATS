import pandas as pd
import os
if not os.path.exists('output/column_counts'):
    os.mkdir('output/column_counts')

df = pd.read_csv('output/input_test.csv.gz')

# for each flucats column, count the number of times each value appears, save as a single csv
counts = []

for col in df.columns:
    if col.startswith('flucats') and col.endswith('code'):
        count = (df[col].value_counts())
        
        # set index of count to multiindex of column name and code
        count.index = pd.MultiIndex.from_product([[col], count.index])
        counts.append(count)

count_comined = pd.concat(counts)
count_comined.to_csv('output/column_counts/combined.csv', header=True, index=True)

