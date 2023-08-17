from cohortextractor import (
    StudyDefinition,
    patients,
)

from codelists import *
from variables.vaccination_variables import vaccination_variables

end_date = "2021-06-30"


study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.8,
    },
    index_date=end_date,
    population=patients.all(),
    died_any=patients.died_from_any_cause(
        on_or_before="index_date",
        returning="binary_flag",
        return_expectations={"incidence": 0.05},
    ),
    died_any_date=patients.died_from_any_cause(
        on_or_before="index_date",
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2020-02-01"},
            "rate": "exponential_increase",
        },
    ),
    covid_related_death=patients.with_these_codes_on_death_certificate(
        covid_death_codelist,  # imported from codelists.py
        returning="binary_flag",
        on_or_before="index_date",
        match_only_underlying_cause=False,
        return_expectations={
            "incidence": 0.05,
        },
    ),
    covid_related_death_date=patients.with_these_codes_on_death_certificate(
        covid_death_codelist,  # imported from codelists.py
        returning="date_of_death",
        on_or_before="index_date",
        match_only_underlying_cause=False,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "index_date", "latest": "today"},
        },
    ),
    covid_death=patients.with_these_codes_on_death_certificate(
        covid_death_codelist,  # imported from codelists.py
        returning="binary_flag",
        on_or_before="index_date",
        match_only_underlying_cause=True,
        return_expectations={
            "incidence": 0.05,
        },
    ),
    covid_death_date=patients.with_these_codes_on_death_certificate(
        covid_death_codelist,  # imported from codelists.py
        returning="date_of_death",
        on_or_before="index_date",
        match_only_underlying_cause=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "index_date", "latest": "today"},
        },
    ),
    **vaccination_variables,
    
)
