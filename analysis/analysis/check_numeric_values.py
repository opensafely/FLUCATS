import pandas as pd
from pathlib import Path


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
        "flucats_question_numeric_value_temperature_703421000",
    ]

    codes = []

    for variable in numeric_variables_list:
        codes.append(variable.split("_")[-1])

    numeric_values_variables_list = [f"{x}_value" for x in numeric_variables_list]

    file_path = Path("output/joined/full/input_all.csv")

    df = pd.read_csv(file_path, usecols=numeric_variables_list.extend(numeric_values_variables_list))

    
    proportions = {}

    for code in codes:
    
        binary_variable = [x for x in numeric_variables_list if code in x][0]
        numeric_value = [x for x in numeric_values_variables_list if code in x][0]

        subset_df = df.loc[df[binary_variable] == 1]

        proportions[code] = round(len(subset_df.loc[subset_df[numeric_value] > 0]) / len(subset_df), 2)

    proportions_numeric = pd.DataFrame(proportions, index=["proportion"])

    proportions_numeric.to_csv("output/joined/full/proportions_numeric.csv")


if __name__ == "__main__":
    main()
