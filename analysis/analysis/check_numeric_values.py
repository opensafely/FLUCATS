import pandas as pd
from pathlib import Path


def calculate_proportions(df, numeric_variables_list, numeric_values_variables_list):
    """
    Calculate the proportion of patients with a numeric value greater than 0 for each variable.
    Args:
        df: input df
        numeric_variables_list: list of binary variables expected to have numeric values attached.
        numeric_values_variables_list: list of numeric value variables with numeric values attached.
    """

    proportions = {}

    for var in numeric_variables_list:
        code = var.split("_")[-1]
        numeric_value = [x for x in numeric_values_variables_list if code in x][0]

        subset_df = df.loc[df[var] == 1]

        if len(subset_df) > 0:
            proportions[code] = round(
                len(subset_df.loc[subset_df[numeric_value] > 0]) / len(subset_df), 2
            )

        else:
            proportions[code] = 0
    proportions_numeric = pd.DataFrame(proportions, index=["proportion"])
    return proportions_numeric


def main():
    numeric_variables_list = [
        "flucats_question_numeric_value_dehydration_or_shock_15527001",
        "flucats_question_numeric_value_dehydration_or_shock_787041000000101",
        "flucats_question_numeric_value_dehydration_or_shock_787051000000103",
        "flucats_question_numeric_value_heart_rate_422119006",
        "flucats_question_numeric_value_heart_rate_429525003",
        "flucats_question_numeric_value_heart_rate_429614003",
        "flucats_question_numeric_value_heart_rate_78564009",
        "flucats_question_numeric_value_heart_rate_843941000000100",
        "flucats_question_numeric_value_respiratory_rate_250810003",
        "flucats_question_numeric_value_respiratory_rate_271625008",
        "flucats_question_numeric_value_respiratory_rate_86290005",
        "flucats_question_numeric_value_respiratory_rate_927961000000102",
        "flucats_question_numeric_value_oxygen_saturation_431314004",
        "flucats_question_numeric_value_oxygen_saturation_927981000000106",
        "flucats_question_numeric_value_oxygen_saturation_852651000000100",
        "flucats_question_numeric_value_oxygen_saturation_852661000000102",
        "flucats_question_numeric_value_oxygen_saturation_866661000000106",
        "flucats_question_numeric_value_oxygen_saturation_866681000000102",
        "flucats_question_numeric_value_oxygen_saturation_866701000000100",
        "flucats_question_numeric_value_oxygen_saturation_866721000000109",
        "flucats_question_numeric_value_temperature_703421000",
    ]

    file_path = Path("output/joined/full/input_all.csv")
    output_path = "output/joined/full/proportions_numeric.csv"

    numeric_values_variables_list = numeric_values_variables_list = [
        f"{x}_value" for x in numeric_variables_list
    ]

    df = pd.read_csv(
        file_path, usecols=numeric_variables_list + numeric_values_variables_list
    )
    proportions_numeric = calculate_proportions(
        df, numeric_variables_list, numeric_values_variables_list
    )
    proportions_numeric.to_csv(output_path)


if __name__ == "__main__":
    main()
