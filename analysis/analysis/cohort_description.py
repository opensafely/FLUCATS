import pandas as pd
import numpy as np
import argparse
import pathlib
from study_utils import OUTPUT_DIR


def match_paths(pattern):
    return sorted(pathlib.Path().glob(pattern))


def load_and_preprocess_csv(path, cols):
    """
    Loads a csv file, fills missing values with "missing" and drops duplicate patient_ids
    (these are only present in the dummy data)
    Args:
        path (str): Path to csv file
        cols (list): List of columns to include in the DataFrame
    Returns:
        pd.DataFrame: DataFrame with columns specified in cols
    """

    df = pd.read_csv(path, usecols=cols)
    df.loc[:, cols] = df.loc[:, cols].fillna("missing")
    df = df.drop_duplicates(subset=["patient_id"], keep="last").reset_index(drop=True)
    return df


def update_df(original_df, new_df, columns=[], on="patient_id"):
    """
    Updates a DataFrame with new values
    Args:
        original_df (pd.DataFrame): DataFrame to update
        new_df (pd.DataFrame): DataFrame with new values
        columns (list): List of columns to update
        on (str): Column to use as index
    Returns:
        pd.DataFrame: Updated DataFrame
    """

    merged_df = pd.merge(original_df, new_df, on=on, how="outer", suffixes=("", "_new"))
    for column in columns:
        merged_df[column].update(merged_df[column + "_new"])
        merged_df = merged_df.drop(columns=[column + "_new"])

    return merged_df


def round_column(column, base):
    return (column / base).round() * base


def group_low_values_df(df):
    """
    Groups low values in a DataFrame. Values are grouped across categories
    Args:
        df (pd.DataFrame): DataFrame to group - expected columns are ["category", "group", "count"]
    Returns:
        pd.DataFrame: DataFrame with low values grouped
    """

    redacted_groups = []

    for cat in df["category"].unique():
        df_subset = df[df["category"] == cat]
        suppressed_count = df_subset.loc[df_subset["count"] <= 7, "count"].sum()

        if suppressed_count == 0:
            df_subset = df_subset.copy()
            df_subset["count"] = round_column(df_subset["count"], 10)
            redacted_groups.append(df_subset)
        else:
            df_subset.loc[df_subset["count"] <= 7, "count"] = np.nan

            while (suppressed_count <= 7) & (df_subset["count"].notnull().any()):
                suppressed_count += df_subset.loc[:, "count"].min()

                df_subset.loc[df_subset["count"].idxmin(), "count"] = np.nan

            if suppressed_count > 7:
                other_row = pd.DataFrame(
                    {"category": cat, "group": "other", "count": suppressed_count},
                    index=[0],
                )

                other_row["count"] = round_column(other_row["count"], 10)
                df_subset = pd.concat([df_subset, other_row])
            df_subset = df_subset[df_subset["count"].notnull()]
            redacted_groups.append(df_subset)

    redacted_df = pd.concat(redacted_groups).reset_index(drop=True)

    return redacted_df

def fix_residential_vars(df):
    """Applies correct logic for homeless and residential_care variables.
    Previously, when a patient was missing a type_of_residence code, they were
    incorrectly assigned to the homeless adn residential_care variables.
    """
    homeless_codes = [
        160700001,
        224226001,
        224228000,
        224229008,
        224231004,
        224232006,
        224233001,
        266935003,
        266940006,
        32911000,
        365510008,
        381751000000106,
        65421000,
    ]
    residential_care_codes = [
        1024771000000108,
        105530003,
        160734000,
        160737007,
        224224003,
        248171000000108,
        394923006,
    ]
    type_of_residence = df["type_of_residence"]

    df["homeless"] = type_of_residence.isin(homeless_codes)
    df["residential_care"] = type_of_residence.isin(residential_care_codes)
    df = df.drop("type_of_residence", axis=1)
    return df


def create_cohort_description(paths, demographics):
    """
    Creates a table 1 from a list of csv files. Loads individual extracts, gets the latest
    value for the demographics of interest and counts the number of patients within each subgroup.
    Returns raw and redacted counts.
    Args:
        paths (list): List of paths to csv files
        demographics (list): List of variables to include
    Returns:
        pd.DataFrame: DataFrame with counts for each variable
        pd.DataFrame: DataFrame with low values grouped
    """

    for i, path in enumerate(paths):
        if i == 0:
            df = load_and_preprocess_csv(path, demographics + ["patient_id"])

        else:
            updated_df = load_and_preprocess_csv(path, demographics + ["patient_id"])

            df = update_df(df, updated_df, columns=demographics)

    df = df.drop("patient_id", axis=1)

    ethnicity_mapping = {
        1: "White - British",
        2: "White - Irish",
        3: "White - Any other White background",
        4: "Mixed - White and Black Caribbean",
        5: "Mixed - White and Black African",
        6: "Mixed - White and Asian",
        7: "Mixed - Any other mixed background",
        8: "Asian or Asian British - Indian",
        9: "Asian or Asian British - Pakistani",
        10: "Asian or Asian British - Bangladeshi",
        11: "Asian or Asian British - Any other Asian background",
        12: "Black or Black British - Caribbean",
        13: "Black or Black British - African",
        14: "Black or Black British - Any other Black background",
        15: " Other Ethnic Groups - Chinese",
        16: "Other Ethnic Groups - Any other ethnic group",
    }

    for col in df.columns:
        if "date" in col:
            df[col] = df[col].str.contains(r"^\d{4}-\d{2}-\d{2}$").astype(int)
        elif "ethnicity" in col:
            df[col] = df[col].map(ethnicity_mapping)
        
    df = fix_residential_vars(df)

    df_counts = df.apply(lambda x: x.value_counts()).T.stack().reset_index()

    df_counts.columns = ["category", "group", "count"]
    df_counts_redacted = group_low_values_df(df_counts)

    return df_counts, df_counts_redacted


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--study_def_paths",
        dest="study_def_paths",
        required=True,
        type=match_paths,
        help="Glob pattern for matching input files",
    )

    parser.add_argument(
        "--demographics",
        dest="demographics",
        nargs="+",
        required=True,
        help="List of variables to include",
    )

    return parser.parse_args()


def main():
    args = parse_args()
    paths = args.study_def_paths
    demographics = args.demographics
    cohort_description, cohort_description_redacted = create_cohort_description(
        paths, demographics
    )

    cohort_description.to_csv(OUTPUT_DIR / "cohort_description.csv", index=False)
    cohort_description_redacted.to_csv(
        OUTPUT_DIR / "cohort_description_redacted.csv", index=False
    )


if __name__ == "__main__":
    main()
