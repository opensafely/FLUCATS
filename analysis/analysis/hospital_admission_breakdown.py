# breakdown of hospital admission within 24hrs of a flucats template by code
import pandas as pd
import numpy as np

df = pd.read_csv("output/input_all_edited.csv")

df["suspected_covid"] = (
    df.filter(regex="flucats_question_suspected_covid").eq(1).any(axis=1)
)

df["probable_covid"] = (
    df.filter(regex="flucats_question_probable_covid").eq(1).any(axis=1)
)


# subset to only columns related to probable covid
probable_subset = df.filter(regex="flucats_question_probable_covid")
suspected_subset = df.filter(regex="flucats_question_suspected_covid")

# value counts of each column
probable_counts = probable_subset.apply(pd.Series.value_counts)
suspected_counts = suspected_subset.apply(pd.Series.value_counts)

# remove columns with less than 7 counts and round to nearest 5
probable_counts[probable_counts <= 7] = np.nan
probable_counts = probable_counts.dropna()
probable_counts = probable_counts.apply(lambda x: round(x / 5) * 5)

suspected_counts[suspected_counts <= 7] = np.nan
suspected_counts = suspected_counts.dropna()
suspected_counts = suspected_counts.apply(lambda x: round(x / 5) * 5)

# save to csv
probable_counts.to_csv("output/results/probable_covid_value_counts.csv")
suspected_counts.to_csv("output/results/suspected_covid_value_counts.csv")


df["suspected_covid"] = df["suspected_covid"].astype(int)
df["probable_covid"] = df["probable_covid"].astype(int)


# save df with value counts of each column - prob covid, suspected covid, prob or suspected covid
df[["probable_covid", "suspected_covid"]].apply(
    pd.Series.value_counts
).to_csv("output/results/cov_status_value_counts.csv")




hosp_within_24hrs = df[df["hosp_24h"] == 1]

hosp_codes = hosp_within_24hrs["hospital_admission_code"]

hosp_codes = hosp_codes.dropna()


counts = hosp_within_24hrs.groupby(
    ["probable_covid", "suspected_covid"]
)["hosp_24h"].value_counts()

counts.to_csv("output/results/hospital_admission_cov_status.csv")

counts[counts <= 7] = np.nan
counts = counts.dropna()

counts = counts.apply(lambda x: round(x / 5) * 5)
counts.to_csv("output/results/hospital_admission_cov_status_redacted.csv")
