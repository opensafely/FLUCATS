from codelists import *
from study_utils import loop_over_codes

flucats_variables_altered_conscious_level = loop_over_codes(
    numeric=False,
    question_str="altered_conscious_level",
    code_list=flucats_altered_consciousness_codelist,
)
flucats_variables_blood_pressure = loop_over_codes(
    numeric=False,
    question_str="blood_pressure",
    code_list=flucats_blood_pressure_reading_codelist,
)
flucats_variables_causing_clinical_concern = loop_over_codes(
    numeric=False,
    question_str="causing_clinical_concern",
    code_list=flucats_causing_clinical_concern_codelist,
)
flucats_variables_dehydration_or_shock = loop_over_codes(
    numeric=False,
    question_str="dehydration_or_shock",
    code_list=flucats_dehydration_or_shock_codelist,
)
flucats_variables_dehydration_or_shock_numeric = loop_over_codes(
    numeric=True,
    question_str="dehydration_or_shock",
    code_list=flucats_dehydration_or_shock_observable_codelist,
)
flucats_variables_heart_rate = loop_over_codes(
    numeric=False, question_str="heart_rate", code_list=flucats_heart_rate_codelist
)
flucats_variables_heart_rate_numeric = loop_over_codes(
    numeric=True,
    question_str="heart_rate",
    code_list=flucats_heart_rate_observable_codelist,
)
flucats_variables_respiratory_rate = loop_over_codes(
    numeric=False,
    question_str="respiratory_rate",
    code_list=flucats_increased_respiratory_rate_codelist,
)
flucats_variables_respiratory_rate_numeric = loop_over_codes(
    numeric=True,
    question_str="respiratory_rate",
    code_list=flucats_increased_respiratory_rate_observable_codelist,
)
flucats_variables_temperature = loop_over_codes(
    numeric=False, question_str="temperature", code_list=flucats_temperature_codelist
)
flucats_variables_temperature_numeric = loop_over_codes(
    numeric=True,
    question_str="temperature",
    code_list=flucats_temperature_observable_codelist,
)
flucats_variables_oxygen_saturation = loop_over_codes(
    numeric=False,
    question_str="oxygen_saturation",
    code_list=flucats_oxygen_saturation_codelist,
)
flucats_variables_oxygen_saturation_numeric = loop_over_codes(
    numeric=True,
    question_str="oxygen_saturation",
    code_list=flucats_oxygen_saturation_observable_codelist,
)
flucats_variables_who_performance_score = loop_over_codes(
    numeric=False,
    question_str="who_performance_score",
    code_list=flucats_who_performance_score_codelist,
)
flucats_variables_severe_respiratory_distress = loop_over_codes(
    numeric=False,
    question_str="severe_respiratory_distress",
    code_list=flucats_severe_respiratory_distress_codelist,
)
flucats_variables_respiratory_exhaustion = loop_over_codes(
    numeric=False,
    question_str="respiratory_exhaustion",
    code_list=flucats_respiratory_exhaustion_or_apnoea_codelist,
)
