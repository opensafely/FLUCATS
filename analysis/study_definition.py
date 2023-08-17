from cohortextractor import StudyDefinition, patients, params

from codelists import *
from variables.demographic_variables import demographic_variables
from variables.comorbidity_variables import comorbidity_variables
from variables.hospital_admission_variables import hospital_admissions_variables
from variables.prescription_variables import prescription_variables
from variables.covid_testing_variables import (
    suspected_covid_variables,
    probable_covid_variables,
)
from variables.flucats_variables import (
    flucats_variables_altered_conscious_level,
    flucats_variables_blood_pressure,
    flucats_variables_causing_clinical_concern,
    flucats_variables_clinical_concern_note,
    flucats_variables_dehydration_or_shock,
    flucats_variables_dehydration_or_shock_numeric,
    flucats_variables_heart_rate,
    flucats_variables_heart_rate_numeric,
    flucats_variables_respiratory_rate,
    flucats_variables_respiratory_rate_numeric,
    flucats_variables_oxygen_saturation,
    flucats_variables_oxygen_saturation_numeric,
    flucats_variables_temperature,
    flucats_variables_temperature_numeric,
    flucats_variables_who_performance_score,
    flucats_variables_severe_respiratory_distress,
    flucats_variables_respiratory_exhaustion,
    flucats_variables_inspired_oxygen,
    flucats_variables_inspired_oxygen_numeric,
)

include_hospital_admissions = params["include_hospital_admissions"]
include_hospital_admissions = include_hospital_admissions == "True"

include_numeric_variables = params["include_numeric_variables"]
include_numeric_variables = include_numeric_variables == "True"


numeric_variables_dict = {
    "dehydration_or_shock": flucats_variables_dehydration_or_shock_numeric,
    "heart_rate": flucats_variables_heart_rate_numeric,
    "respiratory_rate": flucats_variables_respiratory_rate_numeric,
    "temperature": flucats_variables_temperature_numeric,
    "oxygen_saturation": flucats_variables_oxygen_saturation_numeric,
    "inspired_oxygen": flucats_variables_inspired_oxygen_numeric,
}

if include_hospital_admissions:
    hospital_admissions_variables = hospital_admissions_variables

    # we also want to extract flucats template occurences once per period, so we do this with the hosp vars

    hospital_admissions_variables["flucats_template_occurences"] = patients.with_these_clinical_events(
            codelist=codelist(["13044541000006109"], system="snomed"),
            between=["index_date", "last_day_of_month(index_date)"],
            returning="number_of_matches_in_period",
            return_expectations={
                "int": {"distribution": "normal", "mean": 1, "stddev": 1}
            },
        )
else:
    hospital_admissions_variables = {}


varset_names = params["varset"].split(",")
varset_dict = {
    "altered_conscious_level": flucats_variables_altered_conscious_level,
    "blood_pressure": flucats_variables_blood_pressure,
    "causing_clinical_concern": flucats_variables_causing_clinical_concern,
    "clinical_concern_note": flucats_variables_clinical_concern_note,
    "dehydration_or_shock": flucats_variables_dehydration_or_shock,
    "heart_rate": flucats_variables_heart_rate,
    "respiratory_rate": flucats_variables_respiratory_rate,
    "oxygen_saturation": flucats_variables_oxygen_saturation,
    "temperature": flucats_variables_temperature,
    "who_performance_score": flucats_variables_who_performance_score,
    "severe_respiratory_distress": flucats_variables_severe_respiratory_distress,
    "respiratory_exhaustion": flucats_variables_respiratory_exhaustion,
    "demographic_variables": demographic_variables,
    "comorbidity_variables": comorbidity_variables,
    "prescription_variables": prescription_variables,
    "inspired_oxygen": flucats_variables_inspired_oxygen,
    "suspected_covid": suspected_covid_variables,
    "probable_covid": probable_covid_variables,
}

varsets = [varset_dict[varset_name] for varset_name in varset_names]

varset_variables = {}
for d in varsets:
    varset_variables.update(d)

if include_numeric_variables:

    numeric_variables_list = [
        numeric_variables_dict.get(varset_name) for varset_name in varset_names
    ]

else:
    numeric_variables_list = []

# convert list of dicts to single dict
numeric_variables_dict = {
    key: value
    for dictionary in numeric_variables_list
    if dictionary is not None
    for key, value in dictionary.items()
}


study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.5,
    },
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
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.49, "U": 0.01, "I": 0.01}},
        }
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
    **varset_variables,
    **hospital_admissions_variables,
    **numeric_variables_dict,
)
