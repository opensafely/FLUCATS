from cohortextractor import (
    StudyDefinition,
    patients,
)

from codelists import *
from vaccination_variables import vaccination_variables

end_date = "2022-03-27"


study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.8,
    },
    index_date=end_date,
    population=patients.all(),
    
    **vaccination_variables,
    died_any_date=patients.died_from_any_cause(
        on_or_before="index_date",
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest" : "2020-02-01"},
            "rate" : "exponential_increase"
        },
    ),


    died_covid_any_date=patients.with_these_codes_on_death_certificate(
        covid_death_codelist,  # imported from codelists.py
        returning="date_of_death",
        on_or_before="index_date",
        match_only_underlying_cause=False,  # boolean for indicating if filters
        # results to only specified cause of death
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "index_date", "latest": end_date},
            "incidence": 0.05,
        },
    ),

    covid_death=patients.with_these_codes_on_death_certificate(
        covid_death_codelist,  # imported from codelists.py
        returning="date_of_death",
        on_or_before="index_date",
        match_only_underlying_cause=False,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "index_date", "latest": "today"},
            "incidence": 0.05,
        },
    ),
    cause_of_death = patients.died_from_any_cause(
            on_or_before="index_date",
            returning="underlying_cause_of_death",
            return_expectations={
                "category": {
                    "ratios": {
                        "code1": 0.5,
                        "code2": 0.5,
                    }
                }
            },
            
        ),
    place_of_death = patients.died_from_any_cause(
            on_or_before="index_date",
            returning="place_of_death",
            return_expectations={
                "category": {
                    "ratios": {
                        "code1": 0.5,
                        "code2": 0.5,
                    }
                }
            },
        ),

    # Ethnicity
    ethnicity_opensafely=patients.with_these_clinical_events(
        ethnicity_opensafely,
        returning="category",
        find_last_match_in_period=True,
        on_or_before="index_date",
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
        on_or_before="index_date",
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
        on_or_before="index_date",
        date_format="YYYY-MM-DD",
    ),
    # Ethnicity not given - patient refused
    eth_notgiptref_dat=patients.with_these_clinical_events(
        eth_notgiptref,
        returning="date",
        find_last_match_in_period=True,
        on_or_before="index_date",
        date_format="YYYY-MM-DD",
    ),
    # Ethnicity not stated
    eth_notstated_dat=patients.with_these_clinical_events(
        eth_notstated,
        returning="date",
        find_last_match_in_period=True,
        on_or_before="index_date",
        date_format="YYYY-MM-DD",
    ),
    # Ethnicity no record
    eth_norecord_dat=patients.with_these_clinical_events(
        eth_norecord,
        returning="date",
        find_last_match_in_period=True,
        on_or_before="index_date",
        date_format="YYYY-MM-DD",
    ),
    
)