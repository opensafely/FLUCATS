from cohortextractor import patients, codelist


def generate_expectations_codes(codelist, incidence=0.5):
    expectations = {str(x): (1 - incidence) / len(codelist) for x in codelist}
    expectations[None] = incidence
    return expectations


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
            f"flucats_question_numeric_value_{question_str}_{code}_value": patients.with_these_clinical_events(
                codelist([code], system="snomed"),
                between=["flucats_template_date", "flucats_template_date + 1 day"],
                returning="numeric_value",
                find_last_match_in_period=True,
                return_expectations={
                    "float": {"distribution": "normal", "mean": 45.0, "stddev": 20},
                    "incidence": 0.5,
                },
            ),
            f"flucats_question_numeric_value_{question_str}_{code}_code": patients.with_these_clinical_events(
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
