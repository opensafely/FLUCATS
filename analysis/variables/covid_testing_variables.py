from codelists import suspected_covid_codelist, probable_covid_codelist
from analysis.study_utils import generate_expectations_codes
from cohortextractor import patients, codelist

def loop_over_codes_covid(name, code_list):
    def make_variable(code):
        return {
            f"flucats_question_{name}_{code}": patients.with_these_clinical_events(
                codelist([code], system="snomed"),
                between=["flucats_template_date - 14 days", "flucats_template_date + 7 days"],
                returning="binary_flag",
                find_last_match_in_period=True,
                return_expectations={
                    "category": {"ratios": generate_expectations_codes([code])}
                },
            )
        }

    variables = {}
    for code in code_list:
        variables.update(make_variable(code))
    return variables


probable_covid_variables = loop_over_codes_covid(
    name ="probable_covid",
    code_list=probable_covid_codelist,
)

suspected_covid_variables = loop_over_codes_covid(
    name="suspected_covid",
    code_list=suspected_covid_codelist,
)