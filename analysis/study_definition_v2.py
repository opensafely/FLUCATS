from cohortextractor import StudyDefinition, patients, params

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


varset_names = params["varset"].split(",")
varset_dict = {
    "altered_conscious_level": flucats_variables_altered_conscious_level,
    "blood_pressure": flucats_variables_blood_pressure,
    "causing_clinical_concern": flucats_variables_causing_clinical_concern,
    "dehydration_or_shock": flucats_variables_dehydration_or_shock,
    "heart_rate": flucats_variables_heart_rate,
    "respiratory_rate": flucats_variables_respiratory_rate,
    "oxygen_saturation": flucats_variables_oxygen_saturation,
    "temperature": flucats_variables_temperature,
    "who_performance_score": flucats_variables_who_performance_score,
    "severe_respiratory_distress": flucats_variables_severe_respiratory_distress,
    "respiratory_exhaustion": flucats_variables_respiratory_exhaustion,
    "demographic_variables": demographic_variables,
}

varsets = [varset_dict[varset_name] for varset_name in varset_names]

varset_variables = {}
for d in varsets:
    varset_variables.update(d)

print(varset_variables)

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
        sex=patients.sex(
            return_expectations={
                "rate": "universal",
                "category": {"ratios": {"M": 0.49, "F": 0.49, "U": 0.01, "I": 0.01}},
            }
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
    
    **varset_variables
)