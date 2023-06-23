import pandas as pd
from pandas.testing import assert_frame_equal
from analysis.analysis.cohort_description import load_and_preprocess_csv, update_df, group_low_values_df



def test_load_and_preprocess_csv(tmp_path):
    # Prepare input data
    df = pd.DataFrame({
        'patient_id': [1, 2, 1, 3, 3],
        'age': [None, 20, None, 30, None]
    })
    test_file = tmp_path / "test.csv"
    df.to_csv(test_file, index=False)
    cols = ['patient_id', 'age']
    
    expected_output = pd.DataFrame({
        'patient_id': [2, 1, 3],
        'age': [20, 'missing', 'missing']
    })

    output = load_and_preprocess_csv(test_file, cols)
    print(df)
    print(output)
    print(expected_output)
    assert_frame_equal(output, expected_output)

    # Check there are no NaN values
    assert not output.isnull().values.any()

    # Check there are no duplicate patient_ids
    assert not output['patient_id'].duplicated().any()




def test_update_df():

    # Test data
    original_data = {
        "patient_id": [1, 2, 3],
        "age": [30, 25, 35]
    }

    new_data = {
        "patient_id": [2, 3],
        "age": [26, 36]
    }

    expected_data = {
        "patient_id": [1, 2, 3],
        "age": [30, 26, 36]
    }

    original_df = pd.DataFrame(original_data)
    new_df = pd.DataFrame(new_data)
    expected_df = pd.DataFrame(expected_data)
 
    updated_df = update_df(original_df, new_df, columns=["age"])

    pd.testing.assert_frame_equal(updated_df, expected_df, check_dtype=False)




def test_group_low_values_df():

    data = {
        "category": ["A", "A", "B", "B", "B", "C", "C"],
        "group": ["group1", "group2", "group1", "group2", "group3", "group1", "group2"],
        "count": [10, 5, 10, 8, 2, 20, 20]
    }

    expected_data = {
        "category": ["A", "B", "B", "C", "C"],
        "group": ["other", "group1", "other", "group1", "group2"],
        "count": [15, 10, 10, 20, 20]
    }

    df = pd.DataFrame(data)
    expected_df = pd.DataFrame(expected_data)

    grouped_df = group_low_values_df(df)


    pd.testing.assert_frame_equal(grouped_df, expected_df, check_dtype=False)
    assert not grouped_df["count"].isnull().any()
    assert not (grouped_df["count"] <= 7).any()