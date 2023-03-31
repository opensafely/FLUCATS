import pandas as pd
from pathlib import Path
from flucats_variables_v2 import (
    flucats_variables_163020007_numeric,
    flucats_variables_15527001_numeric,
    flucats_variables_787041000000101_numeric,
    flucats_variables_787051000000103_numeric,
    flucats_variables_162986007_numeric,
    flucats_variables_162913005_numeric,
)

def main():
    template_frequencies = []
    numeric_variables_list = [
        "flucats_question_numeric_value_blood_pressure_163020007_value",
        "flucats_question_numeric_value_dehydration_or_shock_15527001_value",
        "flucats_question_numeric_value_dehydration_or_shock_787041000000101_value",
        "flucats_question_numeric_value_dehydration_or_shock_787051000000103_value",
        "flucats_question_numeric_value_heart_rate_162986007_value",
        "flucats_question_numeric_value_respiratory_rate_162913005_value",
    ]
    
    proportions_numeric = []
    for file in Path('output/joined/full').glob('input_v2_2020-03-01.csv.gz'):

        df = pd.read_csv(file, usecols=numeric_variables_list, dtype='float64')
        
        # for each column, calculate proportion where value is not null
     
        proportions = {}
        for column in df.columns:
            proportions[column] = df[column].count() / len(df)
        
        proportions_numeric.append(proportions)
    
    # mean value across months for each variable
    proportions_numeric = pd.DataFrame(proportions_numeric).mean()

    proportions_numeric.to_csv('output/joined/full/proportions_numeric.csv')

        
        



if __name__ == '__main__':
    main()