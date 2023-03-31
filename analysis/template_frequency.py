import pandas as pd
from pathlib import Path

def main():
    template_frequencies = []
    for file in Path('output/joined/full').glob('input_v2*.csv.gz'):

        df = pd.read_csv(file)
        
        template_freq = df['flucats_template_occurences'].value_counts()
     
        template_frequencies.append(template_freq)




    template_freq = pd.concat(template_frequencies)
 
    template_freq = template_freq.value_counts()
    template_freq.index.name = 'template_occurences'
    
    # group the top 5 rows into a single row
    top_5 = template_freq.iloc[:5].sum()
    template_freq = template_freq.iloc[5:]
    template_freq = pd.concat([pd.Series([top_5], index=['5+']), template_freq])

    template_freq = template_freq.rename('number_of_patients').round(-1)
    template_freq.to_csv('output/joined/full/template_frequency.csv')
if __name__ == '__main__':
    main()