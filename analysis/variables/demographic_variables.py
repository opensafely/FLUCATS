from cohortextractor import patients
from codelists import *
from analysis.study_utils import generate_expectations_codes

demographic_variables = dict(
    age=patients.age_as_of(
        "index_date",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),
    age_band=patients.categorised_as(
        {
            "missing": "DEFAULT",
            "<1": """ age = 0""",
            "1-16": """ age >= 1 AND age < 16""",
            "16-19": """ age >=  16 AND age < 20""",
            "20-29": """ age >=  20 AND age < 30""",
            "30-39": """ age >=  30 AND age < 40""",
            "40-49": """ age >=  40 AND age < 50""",
            "50-59": """ age >=  50 AND age < 60""",
            "60-69": """ age >=  60 AND age < 70""",
            "70-79": """ age >=  70 AND age < 80""",
            "80+": """ age >=  80 AND age < 120""",
        },
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "missing": 0.005,
                    "<1": 0.0625,
                    "1-16": 0.0625,
                    "16-19": 0.0625,
                    "20-29": 0.0625,
                    "30-39": 0.125,
                    "40-49": 0.125,
                    "50-59": 0.125,
                    "60-69": 0.125,
                    "70-79": 0.125,
                    "80+": 0.12,
                }
            },
        },
    ),
    type_of_residence=patients.with_these_clinical_events(
        type_of_residence_codelist,
        on_or_before="index_date",
        returning="code",
        find_last_match_in_period=True,
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": generate_expectations_codes(
                    type_of_residence_codelist, incidence=0.8
                )
            },
        },
    ),
    # homeless is latest reside code in homeless codelist
    homeless=patients.satisfying(
        """
        type_of_residence=homeless_code
        """,
        homeless_code=patients.with_these_clinical_events(
            codelist=codelist(homeless_codelist, system="snomed"),
            on_or_before="index_date",
            returning="code",
            find_last_match_in_period=True,
            return_expectations={
                "category": {"ratios": generate_expectations_codes([homeless_codelist])}
            },
        ),
        return_expectations={
            "incidence": 0.05,
        },
    ),
    # residential_care is latest reside code in residential care codelist
    residential_care=patients.satisfying(
        """
        type_of_residence=residential_care_code
        """,
        residential_care_code=patients.with_these_clinical_events(
            codelist=codelist(residential_care_codelist, system="snomed"),
            on_or_before="index_date",
            returning="code",
            find_last_match_in_period=True,
            return_expectations={
                "category": {
                    "ratios": generate_expectations_codes([residential_care_codelist])
                }
            },
        ),
        return_expectations={
            "incidence": 0.1,
        },
    ),
    region=patients.registered_practice_as_of(
        "index_date",
        returning="nuts1_region_name",
        return_expectations={
            "category": {
                "ratios": {
                    "North East": 0.1,
                    "North West": 0.1,
                    "Yorkshire and the Humber": 0.1,
                    "East Midlands": 0.1,
                    "West Midlands": 0.1,
                    "East of England": 0.1,
                    "London": 0.2,
                    "South East": 0.2,
                }
            }
        },
    ),
    imdQ5=patients.categorised_as(
        {
            "Unknown": "DEFAULT",
            "1 (most deprived)": "imd >= 0 AND imd < 32800*1/5",
            "2": "imd >= 32844*1/5 AND imd < 32844*2/5",
            "3": "imd >= 32844*2/5 AND imd < 32844*3/5",
            "4": "imd >= 32844*3/5 AND imd < 32844*4/5",
            "5 (least deprived)": "imd >= 32844*4/5 AND imd <= 32844",
        },
        imd=patients.address_as_of(
            "index_date",
            returning="index_of_multiple_deprivation",
            round_to_nearest=100,
        ),
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "Unknown": 0.05,
                    "1 (most deprived)": 0.19,
                    "2": 0.19,
                    "3": 0.19,
                    "4": 0.19,
                    "5 (least deprived)": 0.19,
                }
            },
            "incidence": 1.0,
        },
    ),
)
