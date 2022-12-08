import pandas as pd
import os

data = []
for file in os.listdir('output'):
  
    if file.startswith('input') and file.endswith('.csv.gz'):
        if not "end" in file:
      
            df = pd.read_csv(f'output/{file}')
          
            df_filtered = df[df['flucats_template'] == 1]
            data.append(df_filtered)

df_combined = pd.concat(data)
df_combined.to_csv('output/input_all_py.csv.gz', index=False)


