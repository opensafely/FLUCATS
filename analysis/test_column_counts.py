import pandas as pd
import os
if not os.path.exists('output/column_counts'):
    os.mkdir('output/column_counts')

df = pd.read_csv('output/input_test.csv.gz')

# for each flucats column, count the number of times each value appears, save as a single csv
counts = []

for col in df.columns:
    if col.startswith('flucats_question'):
        if col.endswith('code'):
        
            count = (df[col].value_counts())
            
        elif col.endswith('value'):
            count = pd.Series((df[col] != 0).count())
            
        else:
            count = pd.Series([0])
        
        # print(count)
        # set index of count to multiindex of column name and code
        count.index = pd.MultiIndex.from_product([[col], count.index])
        counts.append(count)

count_comined = pd.concat(counts)
# set any values <100 and >0 to 100
count_comined = count_comined.apply(lambda x: 100 if x < 100 and x > 0 else x)
# round to nrearest 100
count_comined = count_comined.apply(lambda x: round(x, -2))

count_comined.to_csv('output/column_counts/combined.csv', header=True, index=True)