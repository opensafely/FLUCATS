import pandas as pd
import os

def chunk_and_filter(file):
    filtered = []
    for chunk in pd.read_csv(file, chunksize=100000):
        chunk_filtered = chunk[chunk['flucats_template'] == 1]
        filtered.append(chunk_filtered)
    
    return pd.concat(filtered)


df_1 = chunk_and_filter('output/joined/full/input_2020-03-01.csv.gz')

# all files in output that start with input and end with .csv.gz and don't contain 'end' and are not input_2020-04-01.csv.gz
files = [f for f in os.listdir('output/joined/full') if f.startswith('input') and f.endswith('.csv.gz') and not f.startswith('input_2020-03-01') and not f.endswith('end.csv.gz')]
print(files)
for file in files:
    # read in the file in chunks with pandas
    df_2 = chunk_and_filter(f'output/joined/full/{file}')

    
    df_1 = pd.concat([df_1, df_2])



df_1.to_csv('output/joined/full/input_all_py.csv.gz', index=False)






