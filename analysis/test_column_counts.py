import pandas as pd
import os
if not os.path.exists('output/column_counts'):
    os.mkdir('output/column_counts')




def get_counts(df, filename):
    # for each flucats column, count the number of times each value appears, save as a single csv
    counts = []

    for col in df.columns:
        if col.startswith('flucats_question'):
            if col.endswith('code'):
                
                count = (df[col].value_counts())
                
            elif col.endswith('value'):
            
                df[col] = df[col].astype(int)
                
                count = pd.Series(df[col][df[col] > 0].count())
            
                
            else:
                count = pd.Series([0])
            
            # print(count)
            # set index of count to multiindex of column name and code
            count.index = pd.MultiIndex.from_product([[col], count.index])
            counts.append(count)

    count_comined = pd.concat(counts)


    # set any values <100 0
    count_comined_redacted = count_comined.apply(lambda x: 0 if x < 100 else x)

    # round to nrearest 100
    count_comined_redacted = count_comined_redacted.apply(lambda x: round(x, -2))

    #drop 0 counts
    count_comined_redacted = count_comined_redacted[count_comined_redacted > 0]

    count_comined.to_csv(filename, header=True, index=True)
    count_comined_redacted.to_csv(filename.replace('.csv', '_redacted.csv'), header=True, index=True)

df = pd.read_csv('output/input_test.csv.gz')

get_counts(df, 'output/column_counts/combined.csv')


df_2 = pd.read_csv('output/joined/input_all_py.csv.gz')
df_2 = df_2[df_2['flucats_template'] == 1]

get_counts(df_2, 'output/column_counts/combined_all.csv')