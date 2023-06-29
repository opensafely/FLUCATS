import pandas as pd

df = pd.read_csv("output/joined/full/input_all.csv")

dates = df["date"].unique()
pop_count = {}
for date in sorted(dates):
    count = df[df["date"] == date].shape[0]
    count = int(round(count / 10.0) * 10)
    pop_count[date] = count

df = pd.DataFrame.from_dict(pop_count, orient="index")
df.index.name = "date"
df.columns = ["population_count"]
df.to_csv("output/joined/full/population_count.csv")
