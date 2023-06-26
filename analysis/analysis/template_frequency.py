import pandas as pd


def calculate_template_frequencies(df):
    template_frequencies = []
    for date in df["date"].unique():
        df_subset = df.loc[df["date"] == date]
        template_freq = df_subset["flucats_template_occurences"].value_counts()
        template_frequencies.append(template_freq)
    return pd.concat(template_frequencies, axis=1).fillna(0).sum(axis=1)


def merge_and_order_template_frequencies(template_freq):
    template_freq.index.name = "template_occurences"
    template_freq = template_freq.sort_index()
    five_plus = template_freq.iloc[4:].sum()
    template_freq = template_freq.iloc[:4]
    template_freq = pd.concat([template_freq, pd.Series([five_plus], index=["5+"])])
    return template_freq.rename("number_of_patients").round(-1)


def main():
    df = pd.read_csv("output/joined/full/input_all.csv")
    template_freq = calculate_template_frequencies(df)
    template_freq = merge_and_order_template_frequencies(template_freq)
    template_freq.to_csv("output/joined/full/template_frequency.csv")


if __name__ == "__main__":
    main()
