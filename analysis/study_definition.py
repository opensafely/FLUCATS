from cohortextractor import StudyDefinition, patients

from codelists import *
from demographic_variables import demographic_variables
from comorbidity_variables import comorbidity_variables
from vaccination_variables import vaccination_variables
from flucats_variables import flucats_variables


study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.5,
    },
    index_date = "2020-03-01",

    population = patients.satisfying(
        """
        registered_with_one_practice AND
        (NOT died) AND
        (sex = 'M' OR sex = 'F')
        """,
        registered_with_one_practice = patients.registered_with_one_practice_between(
            "index_date", "index_date + 6 days"
            ),
        died=patients.died_from_any_cause(
            on_or_before="index_date",
            returning="binary_flag",
            return_expectations={"incidence": 0.1},
        ),
    ),
    practice = patients.registered_practice_as_of(
        "index_date",
        returning="pseudo_id",
        return_expectations={
            "int": {"distribution": "normal", "mean": 25, "stddev": 5},
            "incidence": 0.5,
        },
    ),
    **demographic_variables,
    **comorbidity_variables,
    **vaccination_variables,
    **flucats_variables,
    

    
    

)
