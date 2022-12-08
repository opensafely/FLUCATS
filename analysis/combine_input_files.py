import pandas as pd
import os


df_1 = pd.read_csv('output/input_2020-04-01.csv.gz')
df_1_filtered = df_1[df_1['flucats_template'] == 1]

# all files in output that start with input and end with .csv.gz and don't contain 'end' and are not input_2020-04-01.csv.gz
files = [f for f in os.listdir('output') if f.startswith('input') and f.endswith('.csv.gz') and not f.startswith('input_2020-04-01') and not f.endswith('end.csv.gz')]

for file in files:
    print(file)
    df = pd.read_csv(f'output/{file}')
    
    df_filtered = df[df['flucats_template'] == 1]
    df_1_filtered = pd.concat([df_1_filtered, df_filtered])



df_1_filtered.to_csv('output/input_all_py.csv.gz', index=False)






