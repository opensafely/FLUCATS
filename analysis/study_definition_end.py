from cohortextractor import (
    StudyDefinition,
    patients,
)

from codelists import *

end_date = "2021-06-30"


study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.8,
    },
    index_date=end_date,
    population=patients.all(),
    died_any_date=patients.died_from_any_cause(
        on_or_before="index_date",
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2020-02-01"},
            "rate": "exponential_increase",
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
)
