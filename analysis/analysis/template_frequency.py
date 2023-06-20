import pandas as pd
from pathlib import Path

def main():
    template_frequencies = []
    df = pd.read_csv("output/joined/full/input_all.csv")

    for date in df['date'].unique():

        df_subset = df.loc[df['date'] == date]

        template_freq = df_subset['flucats_template_occurences'].value_counts()

        template_frequencies.append(template_freq)


    # merge the template frequencies on the index and sum

    template_freq = pd.concat(template_frequencies, axis=1).fillna(0).sum(axis=1)
    
    
    template_freq.index.name = 'template_occurences'

    # order in ascending order
    template_freq = template_freq.sort_index()

    five_plus = template_freq.iloc[5:].sum()
    template_freq = template_freq.iloc[:5]
    template_freq = pd.concat([template_freq, pd.Series([five_plus], index=['5+'])])

    template_freq = template_freq.rename('number_of_patients').round(-1)
    template_freq.to_csv('output/joined/full/template_frequency.csv')

if __name__ == '__main__':
    main()