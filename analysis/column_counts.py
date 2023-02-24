import pandas as pd
import numpy as np

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
    # get sum of any values <= threshold
    suppressed_count = df.loc[
        df[count_column] <= threshold, count_column
    ].sum()
    suppressed_df = df.loc[df[count_column] > threshold, count_column]
    # if suppressed values >0 ensure total suppressed count > threshold.
    # Also suppress if all values 0
    if (suppressed_count > 0) | (
        (suppressed_count == 0) & (len(suppressed_df) != len(df))
    ):
       
        # redact counts <= threshold
        df.loc[df[count_column] <= threshold, count_column] = np.nan

        # If all values 0, suppress them
        if suppressed_count == 0:
            df.loc[df[count_column] == 0, :] = np.nan

        else:
            # if suppressed count <= threshold redact further values
            while suppressed_count <= threshold:
                suppressed_count += df[count_column].min()
                df.loc[df[count_column].idxmin(), :] = np.nan

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
            min_count = df[count_column].idxmin()
            df.loc[min_count, code_column] = "Other"

    return df

def main():
    
    combined_df = pd.read_csv('output/joined/full/input_v2_all_py.csv.gz', dtype=str)


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
        
        dfs_raw.append(counts_df.reset_index(drop=True))
        counts_df_redacted = counts_df.copy()

        counts_df_redacted = group_low_values(counts_df_redacted, 'count', 'column', 20)

        counts_df_redacted.loc[counts_df_redacted["column"]=="Other", "group"] = group

        # round count column to nearest 10
        counts_df_redacted['count'] = counts_df_redacted['count'].apply(lambda x: round(x, -1))
        # drop col and group columns

        dfs.append(counts_df_redacted.reset_index(drop=True)) 
    # save df

    combined_df = pd.concat(dfs)
    combined_df.to_csv('output/column_counts.csv', index=False)

    combined_df_raw = pd.concat(dfs_raw)
    combined_df_raw.to_csv('output/column_counts_raw.csv', index=False)

if __name__ == "__main__":
    main()