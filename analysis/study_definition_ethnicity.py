from cohortextractor import (
    StudyDefinition,
    patients,
)

from codelists import *

end_date = "2022-06-01"


study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.8,
    },
    index_date=end_date,
    population=patients.all(),
    # Ethnicity
    ethnicity_opensafely=patients.with_these_clinical_events(
        ethnicity_opensafely,
        returning="category",
        find_last_match_in_period=True,
        on_or_before="last_day_of_month(index_date)",
        return_expectations={
            "category": {
                "ratios": {
                    "1": 0.5,
                    "2": 0.4,
                    "3": 0.05,
                    "4": 0.025,
                    "5": 0.025,
                }
            },
            "rate": "universal",
        },
    ),
    ethnicity=patients.with_these_clinical_events(
        eth2001,
        returning="category",
        find_last_match_in_period=True,
        on_or_before="last_day_of_month(index_date)",
        return_expectations={
            "category": {
                "ratios": {
                    "1": 0.5,
                    "2": 0.4,
                    "3": 0.05,
                    "4": 0.025,
                    "5": 0.025,
                }
            },
            "rate": "universal",
        },
    ),
    # Any other ethnicity code
    non_eth2001_dat=patients.with_these_clinical_events(
        non_eth2001,
        returning="date",
        find_last_match_in_period=True,
        on_or_before="last_day_of_month(index_date)",
        date_format="YYYY-MM-DD",
    ),
    # Ethnicity not given - patient refused
    eth_notgiptref_dat=patients.with_these_clinical_events(
        eth_notgiptref,
        returning="date",
        find_last_match_in_period=True,
        on_or_before="last_day_of_month(index_date)",
        date_format="YYYY-MM-DD",
    ),
    # Ethnicity not stated
    eth_notstated_dat=patients.with_these_clinical_events(
        eth_notstated,
        returning="date",
        find_last_match_in_period=True,
        on_or_before="last_day_of_month(index_date)",
        date_format="YYYY-MM-DD",
    ),
    # Ethnicity no record
    eth_norecord_dat=patients.with_these_clinical_events(
        eth_norecord,
        returning="date",
        find_last_match_in_period=True,
        on_or_before="last_day_of_month(index_date)",
        date_format="YYYY-MM-DD",
    ),
)
