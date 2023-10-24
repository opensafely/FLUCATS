import pandas as pd

from hypothesis import given, example, strategies as st

from analysis.analysis.column_counts import group_low_values


@st.composite
def data_frames_st(draw):
    
    all_possible_codes = [f"{i:03}" for i in range(1000)]
    
    num_rows = draw(st.integers(min_value=1, max_value=1000))


    unique_codes = draw(st.lists(st.sampled_from(all_possible_codes), unique=True, min_size=num_rows, max_size=num_rows))
    
    counts = draw(st.lists(st.integers(min_value=0, max_value=100), min_size=num_rows, max_size=num_rows))
    
    return pd.DataFrame({
        'code': unique_codes,
        'count': counts
    })


@given(df=data_frames_st(), threshold=st.integers(min_value=1, max_value=100))
def test_group_low_values(df, threshold):

    code_column = df.columns[0]
    count_column = df.columns[1]

    result_df = group_low_values(df.copy(), count_column, code_column, threshold)
    
    # check all values are greater than threshold
    if result_df.shape[0] > 0:
        assert all(result_df[count_column] > threshold)

    if result_df.shape[0] > 1:

        if "Other" in result_df[code_column].values:

            # check that the sum in the Other row is greater than the threshold
            assert result_df.loc[result_df[code_column] == "Other", count_column].values[0] > threshold

            # if the sum of values below the threshold is less than the threshold, ensure that the next lowest value is redacted

            suppressed_count = df.loc[
                (df[count_column] <= threshold), count_column
            ].sum()

            if suppressed_count <= threshold:
                next_lowest_value = df.loc[df[count_column] > threshold, count_column].idxmin()
                next_lowest_code = df.iloc[next_lowest_value][code_column]
              
                assert next_lowest_code not in result_df[code_column].values

