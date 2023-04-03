import pandas as pd
import numpy as np
import re

def group_low_values(df, count_column, code_column, threshold):
    """Suppresses low values and groups suppressed values into
    a new row "Other".
    Args:
        df: A measure table of counts by code.
        count_column: The name of the count column in the measure table.
        code_column: The name of the code column in the codelist table.
        threshold: Redaction threshold to use
    Returns:
        A table with redacted counts
    """
    df[count_column] = df[count_column].astype(int)
    # get sum of any values <= threshold and > 0
    suppressed_count = df.loc[
        (df[count_column] <= threshold) & (df[count_column] > 0), count_column
    ].sum()
    suppressed_df = df.loc[df[count_column] > threshold, count_column]
    # if suppressed values >0 ensure total suppressed count > threshold.
    if suppressed_count > 0:

        # redact counts <= threshold and > 0
        df.loc[(df[count_column] <= threshold) & (df[count_column] > 0), count_column] = np.nan

        # if suppressed count <= threshold redact further values
        while suppressed_count <= threshold:
            min_count = df[df[count_column] > 0][count_column].idxmin()
            suppressed_count += df.loc[min_count, count_column]
            df.loc[min_count, count_column] = np.nan
            suppressed_df = df.loc[df[count_column] > threshold, count_column]

        # drop all rows where count column is null
        df = df.loc[df[count_column].notnull(), :]

        # add suppressed count as "Other" row (if > threshold)
        if suppressed_count > threshold:
            suppressed_count = {
                code_column: "Other",
                count_column: suppressed_count,
            }
            df = pd.concat(
                [df, pd.DataFrame([suppressed_count])], ignore_index=True
            )

        elif suppressed_count == 0:
            df = df.reset_index(drop=True)
            if len(df) > 0:
                min_count = df[count_column].idxmin()
                df.loc[min_count, code_column] = "Other"

    return df


def main():
    
    combined_df = pd.read_csv('output/joined/full/input_v2_all_py.csv.gz', dtype=str)
    codelist_paths = {
        "altered_conscious_level": "codelists/user-Louis-flucats-altered-conscious-level.csv",
        "blood_pressure": "codelists/user-Louis-flucats-blood-pressure-reading.csv",
        "causing_clinical_concern": "codelists/user-Louis-flucats-causing-clinical-concern.csv",
        "dehydration_or_shock": "codelists/user-Louis-flucats-evidence-of-dehydration-or-shock.csv",
        "heart_rate": "codelists/user-Louis-flucats-heart-rate.csv",
        "respiratory_rate": "codelists/user-Louis-flucats-increased-respiratory-rate.csv",
        "oxygen_saturation": "codelists/user-Louis-flucats-oxygen-saturation.csv",
        "temperature": "codelists/user-Louis-flucats-temperature.csv",
        "who_performance_score": "codelists/user-Louis-flucats-who-performance-score.csv",
        "severe_respiratory_distress": "codelists/user-Louis-flucats-severe-respiratory-distress.csv",
        "respiratory_exhaustion": "codelists/user-Louis-flucats-respiratory-exhaustion-or-apnoea.csv",
    }
    codelists = {k: pd.read_csv(v) for k, v in codelist_paths.items()}

    groups = [
        "altered_conscious_level",
        "blood_pressure",
        "causing_clinical_concern",
        "dehydration_or_shock",
        "heart_rate",
        "respiratory_rate",
        "oxygen_saturation",
        "temperature",
        "who_performance_score",
        "severe_respiratory_distress",
        "respiratory_exhaustion",
        "demographic_variables",
    ]


    dfs= []
    dfs_raw = []

    for group in groups:
        
      
       

        counts_df = pd.DataFrame(columns=['group', 'column', 'count'])
        
        columns = [col for col in combined_df.columns if col.startswith(f'flucats_question_{group}')]
    
        subset = combined_df[columns]

        
        for col in subset.columns:
            row = pd.DataFrame({'group': group, 'column': col, 'count': subset[col].count()}, index=pd.MultiIndex.from_tuples([(group, col)]))
            counts_df = pd.concat([counts_df, row])   
        
        # use regex to rename column from e.g. flucats_question_altered_conscious_level_162701007_code to 162701007
        
        pattern = r"(\d+)_code"
        counts_df['column'] = counts_df['column'].str.extract(pattern)

        
        # convert to int
        counts_df['column'] = counts_df['column'].astype(int)

        # rename column to code
        counts_df = counts_df.rename(columns={'column': 'code'})

  
        

        dfs_raw.append(counts_df.reset_index(drop=True))


          # get code description from codelist
        if not group == 'demographic_variables':
            codelist = codelists[group]
            counts_df = counts_df.merge(codelist, on='code', how='left')

            # reorder - group, code, description, count
            counts_df = counts_df[['group', 'code', 'term', 'count']]


        counts_df_redacted = counts_df.copy()

        counts_df_redacted = group_low_values(counts_df_redacted, 'count', 'code', 7)
        
        if len(counts_df_redacted)>0:
       
            counts_df_redacted.loc[counts_df_redacted['code']=='Other', 'term'] = ''
            counts_df_redacted.loc[counts_df_redacted['code']=='Other', 'group'] = group      

        # round count column to nearest 10
        counts_df_redacted['count'] = counts_df_redacted['count'].apply(lambda x: round(x, -1))
        # drop col and group columns

        dfs.append(counts_df_redacted.reset_index(drop=True)) 
    # save df

    combined_df = pd.concat(dfs)

    # remove rows where count is 0
    combined_df = combined_df.loc[combined_df['count'] > 0, :]

    combined_df.to_csv('output/column_counts.csv', index=False)

    combined_df_raw = pd.concat(dfs_raw)
    combined_df_raw.to_csv('output/column_counts_raw.csv', index=False)

if __name__ == "__main__":
    main()