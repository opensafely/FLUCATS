import pytest
import pandas as pd
from pandas.testing import assert_frame_equal
from analysis.analysis.check_numeric_values import calculate_proportions

@pytest.fixture
def input_df():
    df = pd.DataFrame(
        {
            "flucats_question_numeric_value_dehydration_or_shock_15527001": [0, 1, 1, 1, 1],
            "flucats_question_numeric_value_dehydration_or_shock_15527001_value": [0, 0, 20, 10, 20],
            "flucats_question_numeric_value_dehydration_or_shock_787041000000101": [0, 0, 1, 1, 1],
            "flucats_question_numeric_value_dehydration_or_shock_787041000000101_value": [0, 0, 20, 10, 20],
            "flucats_question_numeric_value_heart_rate_422119006": [0, 1, 1, 1, 1],
            "flucats_question_numeric_value_heart_rate_422119006_value": [0, 0, 0, 10, 20],
            "flucats_question_numeric_value_heart_rate_429525003": [0, 0, 0, 0, 0],
            "flucats_question_numeric_value_heart_rate_429525003_value": [0, 0, 0, 0, 0],

        }
    )
    return df

@pytest.fixture
def numeric_variables_list():
    list = [
        "flucats_question_numeric_value_dehydration_or_shock_15527001",
        "flucats_question_numeric_value_dehydration_or_shock_787041000000101",
        "flucats_question_numeric_value_heart_rate_422119006",
        "flucats_question_numeric_value_heart_rate_429525003",
    ]
    return list

@pytest.fixture
def numeric_values_variables_list():
    list = [
        "flucats_question_numeric_value_dehydration_or_shock_15527001_value",
        "flucats_question_numeric_value_dehydration_or_shock_787041000000101_value",
        "flucats_question_numeric_value_heart_rate_422119006_value",
        "flucats_question_numeric_value_heart_rate_429525003_value",
    ]
    return list


def test_calculate_proportions(input_df, numeric_variables_list, numeric_values_variables_list):
    expected_output = pd.DataFrame(
        {
            "15527001": [75.00],
            "787041000000101": [100.00],
            "422119006": [50.00],
        },
        index=["proportion"]
    )
    output = calculate_proportions(input_df, numeric_variables_list, numeric_values_variables_list)
    assert_frame_equal(output, expected_output)
