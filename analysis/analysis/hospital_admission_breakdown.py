# breakdown of hospital admission within 24hrs of a flucats template by code
import pandas as pd
import numpy as np

df = pd.read_csv('output/input_all_edited.csv')

hosp_within_24hrs = df[df["hosp_24h"] == 1]

hosp_codes = hosp_within_24hrs["hospital_admission_code"]

hosp_codes = hosp_codes.dropna()
counts = hosp_codes.value_counts()
counts[counts <= 7] = np.nan
counts = counts.dropna()

counts = counts.apply(lambda x: round(x/5)*5)
counts.to_csv('output/results/hospital_admission_breakdown.csv')