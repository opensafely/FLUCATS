from cohortextractor import StudyDefinition, patients


from flucats_variables import (
    flucats_variables,
    flucats_variables_numeric,
    flucats_variables_numeric_codes,
    flucats_variables_other,
    flucats_variables_5,
    flucats_variables_11, 
    flucats_variables_20, 
    flucats_variables_37, 
    flucats_variables_45, 
    flucats_variables_29, 
    flucats_variables_30
)

from study_utils import generate_expectations_codes
from codelists import *

# use this to get indidivual code variables for questions in flucat_individual_question_numbers
def loop_over_codes(numeric, question_number):
    def make_variable(code):
        return {
            f"flucats_question_{question_number}_{code}_code": patients.with_these_clinical_events(
                codelist([code], system="snomed"),
                on_or_before="2021-01-01",
                returning="code",
                find_last_match_in_period=True,
                return_expectations={
                    "category": {"ratios": generate_expectations_codes([code])}
                },
            )
        }

    def make_variable_numeric(code):
        return {
            f"flucats_question_{question_number}_{code}_numeric_value": patients.with_these_clinical_events(
                codelist([code], system="snomed"),
                on_or_before="2021-01-01",
                returning="numeric_value",
                find_last_match_in_period=True,
                return_expectations={
                    "float": {"distribution": "normal", "mean": 45.0, "stddev": 20},
                    "incidence": 0.5,
                },
            ),
            f"flucats_question_{question_number}_{code}_code": patients.with_these_clinical_events(
                codelist([code], system="snomed"),
                on_or_before="2021-01-01",
                returning="code",
                find_last_match_in_period=True,
                return_expectations={
                    "category": {"ratios": generate_expectations_codes([code])}
                },
            ),
        }

    variables = {}

    if numeric:
        code_list = flucats_codelists_individual_numeric[str(question_number)]
        for code in code_list:
            variables.update(make_variable_numeric(code))

    else:

        code_list = flucats_codelists_individual[str(question_number)]
        for code in code_list:
            variables.update(make_variable(code))
    return variables


flucats_variables_5 = loop_over_codes(numeric=False, question_number=5)
flucats_variables_11 = loop_over_codes(numeric=False, question_number=11)
flucats_variables_20 = loop_over_codes(numeric=False, question_number=20)
flucats_variables_37 = loop_over_codes(numeric=False, question_number=37)
flucats_variables_45 = loop_over_codes(numeric=False, question_number=45)

flucats_variables_30 = loop_over_codes(numeric=True, question_number=30)
flucats_variables_29 = loop_over_codes(numeric=True, question_number=29)

flucats_variables = {
    f"flucats_question_{str(i)}_code": patients.with_these_clinical_events(
        flucats_codelists[str(i)],
        on_or_before="2021-01-01",
        returning="code",
        find_last_match_in_period=True,
        return_expectations={
            "category": {
                "ratios": generate_expectations_codes(flucats_codelists[str(i)])
            }
        },
    )
    for i in flucat_question_numbers
}

flucats_variables_numeric = {
    f"flucats_question_{str(i)}_numeric_value": patients.with_these_clinical_events(
        flucats_codelists_numeric[str(i)],
        on_or_before="2021-01-01",
        returning="numeric_value",
        find_last_match_in_period=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 45.0, "stddev": 20},
            "incidence": 0.5,
        },
    )
    for i in flucat_question_numbers_numeric
    if i not in flucat_individual_question_numbers_numeric
}

flucats_variables_numeric_codes = {
    f"flucats_question_{str(i)}_numeric_code": patients.with_these_clinical_events(
        flucats_codelists_numeric[str(i)],
        on_or_before="2021-01-01",
        returning="code",
        find_last_match_in_period=True,
        return_expectations={
            "category": {
                "ratios": generate_expectations_codes(flucats_codelists_numeric[str(i)])
            }
        },
    )
    for i in flucat_question_numbers_numeric
    if i not in flucat_individual_question_numbers_numeric
}

# these contain codes that are not available in opencodelists or not part of a question
flucats_variables_other = dict(
    flucats_template=patients.with_these_clinical_events(
        codelist=codelist(["13044541000006109"], system="snomed"),
        on_or_before="2021-01-01",
        returning="binary_flag",
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        find_last_match_in_period=True,
        return_expectations={"incidence": 0.5},
    ),
    flucats_question_8_code=patients.with_these_clinical_events(
        codelist(
            ["81765008", "939761000006103", "939771000006105", "939781000006108"],
            system="snomed",
        ),
        on_or_before="2021-01-01",
        returning="code",
        find_last_match_in_period=True,
        return_expectations={
            "category": {
                "ratios": generate_expectations_codes(
                    [
                        "81765008",
                        "939761000006103",
                        "939771000006105",
                        "939781000006108",
                    ]
                )
            }
        },
    ),
    flucats_question_13_code=patients.with_these_clinical_events(
        codelist=codelist(["62315008", "939811000006105"], system="snomed"),
        on_or_before="2021-01-01",
        returning="code",
        find_last_match_in_period=True,
        return_expectations={
            "category": {
                "ratios": generate_expectations_codes(["62315008", "939811000006105"])
            }
        },
    ),
    flucats_question_17_code=patients.with_these_clinical_events(
        codelist=codelist(["851581000006108", "851601000006103"], system="snomed"),
        on_or_before="2021-01-01",
        returning="code",
        find_last_match_in_period=True,
        return_expectations={
            "category": {
                "ratios": generate_expectations_codes(
                    ["851581000006108", "851601000006103"]
                )
            }
        },
    ),
    flucats_question_43_code=patients.with_these_clinical_events(
        codelist=codelist(
            [
                "183452005",
                "266750002",
                "386473003",
                "408382000",
                "199791000000108",
                "1321231000000101",
                "1850001000006100",
            ],
            system="snomed",
        ),
        on_or_before="2021-01-01",
        returning="code",
        find_last_match_in_period=True,
        return_expectations={
            "category": {
                "ratios": generate_expectations_codes(
                    [
                        "183452005",
                        "266750002",
                        "386473003",
                        "408382000",
                        "199791000000108",
                        "1321231000000101",
                        "1850001000006100",
                    ]
                )
            }
        },
    ),
    flucats_other_covid_confirmed_test_code=patients.with_these_clinical_events(
        codelist=codelist(["1300721000000109"], system="snomed"),
        on_or_before="2021-01-01",
        returning="code",
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        find_last_match_in_period=True,
        return_expectations={
            "category": {"ratios": generate_expectations_codes(["1300721000000109"])}
        },
    ),
    flucats_other_covid_confirmed_diagnostic_code=patients.with_these_clinical_events(
        codelist=codelist(["1300731000000106"], system="snomed"),
        on_or_before="2021-01-01",
        returning="code",
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        find_last_match_in_period=True,
        return_expectations={
            "category": {"ratios": generate_expectations_codes(["1300731000000106"])}
        },
    ),
    flucats_other_covid_antigen_code=patients.with_these_clinical_events(  #
        codelist=codelist(["1322781000000102", "1322791000000100"], system="snomed"),
        on_or_before="2021-01-01",
        returning="code",
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        find_last_match_in_period=True,
        return_expectations={
            "category": {
                "ratios": generate_expectations_codes(
                    ["1322781000000102", "1322791000000100"]
                )
            }
        },
    ),
    flucats_other_covid_rna_code=patients.with_these_clinical_events(  #
        codelist=codelist(["1324581000000102", "1324601000000106"], system="snomed"),
        on_or_before="2021-01-01",
        returning="code",
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        find_last_match_in_period=True,
        return_expectations={
            "category": {
                "ratios": generate_expectations_codes(
                    ["1324581000000102", "1324601000000106"]
                )
            }
        },
    ),
    flucats_urine_code=patients.with_these_clinical_events(
        codelist=codelist(["718403007", "2472002"], system="snomed"),
        on_or_before="2021-01-01",
        returning="code",
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        find_last_match_in_period=True,
        return_expectations={
            "category": {
                "ratios": generate_expectations_codes(["718403007", "2472002"])
            }
        },
    ),
    flucats_pneumonia_code=patients.with_these_clinical_events(
        flucats_pneumonia_codelist,
        on_or_before="2021-01-01",
        returning="code",
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        find_last_match_in_period=True,
        return_expectations={
            "category": {
                "ratios": generate_expectations_codes(flucats_pneumonia_codelist)
            }
        },
    ),
    flucats_icu_code=patients.with_these_clinical_events(
        flucats_icu_codelist,
        on_or_before="2021-01-01",
        returning="code",
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        find_last_match_in_period=True,
        return_expectations={
            "category": {"ratios": generate_expectations_codes(flucats_icu_codelist)}
        },
    ),
    flucats_clinical_concern_note_code=patients.with_these_clinical_events(
        codelist=flucats_clinical_concern_note_codelist,
        on_or_before="2021-01-01",
        returning="code",
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        find_last_match_in_period=True,
        return_expectations={
            "category": {
                "ratios": generate_expectations_codes(
                    flucats_clinical_concern_note_codelist
                )
            }
        },
    ),
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
        sex=patients.sex(
            return_expectations={
                "rate": "universal",
                "category": {"ratios": {"M": 0.49, "F": 0.49, "U": 0.01, "I": 0.01}},
            }
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
    admission_to_icu=patients.with_these_clinical_events(
        flucats_icu_codelist,
        between=["index_date", "index_date + 6 days"],
        returning="code",
        find_last_match_in_period=True,
        return_expectations={
            "category": {
                "ratios": {
                    "code1": 0.5,
                    "code2": 0.5,
                }
            }
        },
    ),
    flucats_clinical_concern_note=patients.with_these_clinical_events(
        flucats_clinical_concern_note_codelist,
        between=["index_date", "index_date + 6 days"],
        returning="binary_flag",
        find_last_match_in_period=True,
    ),
    **flucats_variables_other,
    **flucats_variables,
    **flucats_variables_numeric,
    **flucats_variables_numeric_codes,
    **flucats_variables_5,
    **flucats_variables_11,
    **flucats_variables_20,
    **flucats_variables_37,
    **flucats_variables_45,
    **flucats_variables_29,
    **flucats_variables_30,


)
