from cohortextractor import patients
from codelists import *
from analysis.study_utils import generate_expectations_codes

hospital_admissions_variables = {
        "hospital_admission": patients.with_these_clinical_events(
            codelist=flucats_hospital_admission_codelist,
            between=["index_date", "last_day_of_month(index_date)"],
            returning="binary_flag",
            include_date_of_match=True,
            date_format="YYYY-MM-DD",
            find_last_match_in_period=True,
            return_expectations={"incidence": 0.5},
        ),
        "hospital_admission_code": patients.with_these_clinical_events(
            codelist=flucats_hospital_admission_codelist,
            between=["index_date", "last_day_of_month(index_date)"],
            returning="code",
            include_date_of_match=True,
            date_format="YYYY-MM-DD",
            find_last_match_in_period=True,
            return_expectations=generate_expectations_codes(flucats_hospital_admission_codelist),
        ),
        "icu_admission": patients.with_these_clinical_events(
            codelist=flucats_icu_codelist,
            between=["index_date", "last_day_of_month(index_date)"],
            returning="binary_flag",
            include_date_of_match=True,
            date_format="YYYY-MM-DD",
            find_last_match_in_period=True,
            return_expectations={"incidence": 0.5},
        ),
        "icu_admission_code": patients.with_these_clinical_events(
            codelist=flucats_icu_codelist,
            between=["index_date", "last_day_of_month(index_date)"],
            returning="code",
            include_date_of_match=True,
            date_format="YYYY-MM-DD",
            find_last_match_in_period=True,
            return_expectations=generate_expectations_codes(flucats_icu_codelist),
        )
        
    }