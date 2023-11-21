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
    died_any_date_pc=patients.with_death_recorded_in_primary_care(
        on_or_before="index_date",
        returning="date_of_death",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest" : "2020-02-01"},
            "rate" : "exponential_increase"
        },
    ),
    died_any_pc=patients.with_death_recorded_in_primary_care(
        on_or_before="index_date",
        returning="binary_flag",
    ),
   
    **vaccination_variables,
    
)
