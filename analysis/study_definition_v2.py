from cohortextractor import StudyDefinition, patients

from codelists import *
from demographic_variables import demographic_variables
from flucats_variables_v2 import (
    flucats_variables_altered_conscious_level,
    flucats_variables_blood_pressure,
    flucats_variables_causing_clinical_concern,
    flucats_variables_dehydration_or_shock,
    flucats_variables_heart_rate,
    flucats_variables_respiratory_rate,
    flucats_variables_oxygen_saturation,
    flucats_variables_temperature,
    flucats_variables_who_performance_score,
    flucats_variables_severe_respiratory_distress,
    flucats_variables_respiratory_exhaustion
)


study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.5,
    },
    nulldate = patients.fixed_value("1900-01-01"),
    index_date="2020-03-01",
    population=patients.satisfying(
        """
        registered_with_one_practice AND
        (NOT died) AND
        (sex = 'M' OR sex = 'F') AND
        flucats_template
        """,
        registered_with_one_practice=patients.registered_with_one_practice_between(
            "index_date", "index_date + 6 days"
        ),
        died=patients.died_from_any_cause(
            on_or_before="index_date",
            returning="binary_flag",
            return_expectations={"incidence": 0.1},
        ),
    ),
    practice=patients.registered_practice_as_of(
        "index_date",
        returning="pseudo_id",
        return_expectations={
            "int": {"distribution": "normal", "mean": 25, "stddev": 5},
            "incidence": 0.5,
        },
    ),
    flucats_template=patients.with_these_clinical_events(
        codelist=codelist(["13044541000006109"], system="snomed"),
        between=["index_date", "last_day_of_month(index_date)"],
        returning="binary_flag",
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        find_last_match_in_period=True,
        return_expectations={"incidence": 0.5},
    ),

    **flucats_variables_altered_conscious_level,
    **flucats_variables_blood_pressure,
    **flucats_variables_causing_clinical_concern,
    **flucats_variables_dehydration_or_shock,
    **flucats_variables_heart_rate,
    **flucats_variables_respiratory_rate,
    **flucats_variables_oxygen_saturation,
    **flucats_variables_temperature,
    **flucats_variables_who_performance_score,
    **flucats_variables_severe_respiratory_distress,
    **flucats_variables_respiratory_exhaustion,
    **demographic_variables,
)
