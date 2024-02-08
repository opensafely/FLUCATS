# breakdown of hospital admission within 24hrs of a flucats template by code
import pandas as pd

df = pd.read_csv('output/input_all_edited.csv')

hosp_within_24hrs = df[df["hosp_24h"] == 1]
print(len(hosp_within_24hrs))
codes = hosp_within_24hrs["hospital_admission_code"].value_counts()

codes.to_csv('output/results/hospital_admission_breakdown.csv')