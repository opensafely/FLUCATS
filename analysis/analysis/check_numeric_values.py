import pandas as pd
from pathlib import Path


def main():

    numeric_variables_list = [
        "flucats_question_numeric_value_dehydration_or_shock_15527001_value",
        "flucats_question_numeric_value_dehydration_or_shock_787041000000101_value",
        "flucats_question_numeric_value_dehydration_or_shock_787051000000103_value",
        "flucats_question_numeric_value_heart_rate_422119006_value",
        "flucats_question_numeric_value_heart_rate_429525003_value",
        "flucats_question_numeric_value_heart_rate_429614003_value",
        "flucats_question_numeric_value_heart_rate_78564009_value",
        "flucats_question_numeric_value_heart_rate_843941000000100_value",
        "flucats_question_numeric_value_respiratory_rate_250810003_value",
        "flucats_question_numeric_value_respiratory_rate_271625008_value",
        "flucats_question_numeric_value_respiratory_rate_86290005_value",
        "flucats_question_numeric_value_respiratory_rate_927961000000102_value",
        "flucats_question_numeric_value_oxygen_saturation_431314004_value",
        "flucats_question_numeric_value_oxygen_saturation_927981000000106_value",
        "flucats_question_numeric_value_temperature_703421000_value",
    ]

    proportions_numeric = []
    file_path = Path("output/joined/full/input_all.csv")

    df = pd.read_csv(file_path, usecols=numeric_variables_list, dtype="float64")

    # for each column, calculate proportion where value is not null

    proportions = {}
    for column in df.columns:
        proportions[column] = round(len(df.loc[df[column] > 0]) / len(df), 2)

    proportions_numeric.append(proportions)

    # mean value across months for each variable
    proportions_numeric = pd.DataFrame(proportions_numeric).mean()

    proportions_numeric.to_csv("output/joined/full/proportions_numeric.csv")


if __name__ == "__main__":
    main()
