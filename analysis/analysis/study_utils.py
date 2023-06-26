import re

from pathlib import Path
from cohortextractor import patients, codelist

BASE_DIR = Path(__file__).parents[1]
OUTPUT_DIR = BASE_DIR / "../output"
ANALYSIS_DIR = BASE_DIR / "../analysis"


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
            f"flucats_question_numeric_value_{question_str}_{code}": patients.with_these_clinical_events(
                codelist([code], system="snomed"),
                between=["flucats_template_date", "flucats_template_date + 1 day"],
                returning="binary_flag",
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


def match_input_files(file: str) -> bool:
    pattern = (
        r"^input_([a-zA-Z]+\_)*20\d\d-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])\.csv"
    )
    return bool(re.match(pattern, file))


def get_date_input_file(file: str) -> str:
    """
    Gets the date in format YYYY-MM-DD from input file name string
    """

    if not match_input_files(file):
        raise Exception("Not valid input file format")
    date = re.search(r"(\d{4}-\d{2}-\d{2})", file)
    return date.group(1)
