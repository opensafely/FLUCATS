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
df["suspected_covid"] = df["suspected_covid"].astype(int)
df["probable_covid"] = df["probable_covid"].astype(int)


df["probable_or_suspected_covid"] = (df["probable_covid"] == 1) | (
    df["suspected_covid"] == 1
)
df["probable_or_suspected_covid"] = df["probable_or_suspected_covid"].astype(int)

# save df with value counts of each column - prob covid, suspected covid, prob or suspected covid
df[["probable_covid", "suspected_covid", "probable_or_suspected_covid"]].apply(
    pd.Series.value_counts
).to_csv("output/results/cov_status_value_counts.csv")




hosp_within_24hrs = df[df["hosp_24h"] == 1]

hosp_codes = hosp_within_24hrs["hospital_admission_code"]

hosp_codes = hosp_codes.dropna()


counts = hosp_within_24hrs.groupby(
    ["probable_covid", "suspected_covid", "probable_or_suspected_covid"]
)["hosp_24h"].value_counts()

counts.to_csv("output/results/hospital_admission_cov_status.csv")

counts[counts <= 7] = np.nan
counts = counts.dropna()

counts = counts.apply(lambda x: round(x / 5) * 5)
counts.to_csv("output/results/hospital_admission_cov_status_redacted.csv")
