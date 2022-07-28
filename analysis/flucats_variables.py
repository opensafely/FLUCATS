from cohortextractor import patients, codelist
from codelists import *


flucats_variables = {
    f"flucats_question_{i}": patients.with_these_clinical_events(
        flucats_codelists[str(i)],
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
    )
    for i in flucat_question_numbers
}

flucats_variables_numeric = {
    f"flucats_question_{i}": patients.with_these_clinical_events(
        flucats_codelists_numeric[str(i)],
        between=["index_date", "index_date + 6 days"],
        returning="numeric_value",
        find_last_match_in_period=True,
        return_expectations={
            "int": {"distribution": "normal", "mean": 25, "stddev": 5},
            "incidence": 0.5,
        },
    )
    for i in flucat_question_numbers_numeric
}


flucats_variables_other = dict(
    flucats_question_8=patients.with_these_clinical_events(
        codelist(
            [81765008, 939761000006103, 939771000006105, 939781000006108],
            system="snomed",
        ),
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
    flucats_question_13=patients.with_these_clinical_events(
        codelist([62315008, 939811000006105], system="snomed"),
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
    flucats_question_17=patients.with_these_clinical_events(
        codelist([851581000006108, 851601000006103], system="snomed"),
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
    flucats_question_43=patients.with_these_clinical_events(
        codelist(
            [
                183452005,
                266750002,
                386473003,
                408382000,
                199791000000108,
                1321231000000101,
                1850001000006100,
            ],
            system="snomed",
        ),
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
    flucats_other_covid_confirmed_test=patients.with_these_clinical_events(
        codelist([1300721000000109], system="snomed"),
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
    flucats_other_covid_confirmed_diagnostic=patients.with_these_clinical_events(
        codelist([1300731000000106], system="snomed"),
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
    flucats_other_covid_antigen=patients.with_these_clinical_events(
        codelist([1322781000000102, 1322791000000100], system="snomed"),
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
    flucats_other_covid_rna=patients.with_these_clinical_events(
        codelist([1324581000000102, 1324601000000106], system="snomed"),
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
    flucats_urine=patients.with_these_clinical_events(
        codelist([718403007, 2472002], system="snomed"),
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
    flucats_template=patients.with_these_clinical_events(
        codelist([13044541000006109], system="snomed"),
        between=["index_date", "index_date + 6 days"],
        returning="binary_flag",
        find_last_match_in_period=True,
    ),
    flucats_pneumonia=patients.with_these_clinical_events(
        flucats_pneumonia_codelist,
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
    flucats_icu=patients.with_these_clinical_events(
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
)
