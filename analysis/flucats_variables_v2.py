from cohortextractor import patients, codelist
from codelists import *
from study_utils import generate_expectations_codes


def loop_over_codes(numeric, question_str, code_list):
    def make_variable(code):
        return {
            f"flucats_question_{question_str}_{code}_code": patients.with_these_clinical_events(
                codelist([code], system="snomed"),
                between=["flucats_template_date", "flucats_template_date + 1 day"],
                returning="code",
                find_last_match_in_period=True,
                return_expectations={
                    "category": {"ratios": generate_expectations_codes([code])}
                },
            )
        }

    def make_variable_numeric(code):
        return {
            f"flucats_question_{question_str}_{code}_numeric_value": patients.with_these_clinical_events(
                codelist([code], system="snomed"),
                between=["flucats_template_date", "flucats_template_date + 1 day"],
                returning="numeric_value",
                find_last_match_in_period=True,
                return_expectations={
                    "float": {"distribution": "normal", "mean": 45.0, "stddev": 20},
                    "incidence": 0.5,
                },
            ),
            f"flucats_question_{question_str}_{code}_code": patients.with_these_clinical_events(
                codelist([code], system="snomed"),
                between=["flucats_template_date", "flucats_template_date + 1 day"],
                returning="code",
                find_last_match_in_period=True,
                return_expectations={
                    "category": {"ratios": generate_expectations_codes([code])}
                },
            ),
        }

    variables = {}

    if numeric:
        for code in code_list:
            variables.update(make_variable_numeric(code))

    else:
        for code in code_list:
            variables.update(make_variable(code))
    return variables

flucats_variables_altered_conscious_level = loop_over_codes(numeric=False, question_str="altered_conscious_level", code_list=flucats_altered_consciousness_codelist)
flucats_variables_blood_pressure = loop_over_codes(numeric=False, question_str="blood_pressure", code_list=flucats_blood_pressure_reading_codelist)
flucats_variables_causing_clinical_concern = loop_over_codes(numeric=False, question_str="causing_clinical_concern", code_list=flucats_causing_clinical_concern_codelist)
flucats_variables_dehydration_or_shock = loop_over_codes(numeric=False, question_str="dehydration_or_shock", code_list=flucats_dehydration_or_shock_codelist)
flucats_variables_heart_rate = loop_over_codes(numeric=False, question_str="heart_rate", code_list=flucats_heart_rate_codelist)
flucats_variables_respiratory_rate = loop_over_codes(numeric=False, question_str="respiratory_rate", code_list=flucats_increased_respiratory_rate_codelist)
flucats_variables_temperature = loop_over_codes(numeric=False, question_str="temperature", code_list=flucats_temperature_codelist)
flucats_variables_oxygen_saturation = loop_over_codes(numeric=False, question_str="oxygen_saturation", code_list=flucats_oxygen_saturation_codelist)
flucats_variables_who_performance_score = loop_over_codes(numeric=False, question_str="who_performance_score", code_list=flucats_who_performance_score_codelist)
flucats_variables_severe_respiratory_distress = loop_over_codes(numeric=False, question_str="severe_respiratory_distress", code_list=flucats_severe_respiratory_distress_codelist)
flucats_variables_respiratory_exhaustion = loop_over_codes(numeric=False, question_str="respiratory_exhaustion", code_list=flucats_respiratory_exhaustion_or_apnoea_codelist)
