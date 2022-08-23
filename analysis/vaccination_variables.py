from cohortextractor import patients
from codelists import *

vaccination_variables = dict(
    ###############################################################################
    # COVID VACCINATION
    ###############################################################################
    # any COVID vaccination (first dose)
    covid_vacc_date=patients.with_tpp_vaccination_record(
        target_disease_matches="SARS-2 CORONAVIRUS",
        on_or_after="2020-12-01",  # check all december to date
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {
                "earliest": "2020-12-08",  # first vaccine administered on the 8/12
                "latest": "index_date",
            },
            "incidence": 0.9,
        },
    ),

    # SECOND DOSE COVID VACCINATION
    covid_vacc_second_dose_date=patients.with_tpp_vaccination_record(
        target_disease_matches="SARS-2 CORONAVIRUS",
        on_or_after="covid_vacc_date + 19 days",
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {
                "earliest": "2020-12-29",  # first reported second dose administered on the 29/12
                "latest": "index_date",
            },
            "incidence": 0.8,
        },
    ),

    # BOOSTER (3rd) DOSE COVID VACCINATION
    ## Booster dose scehdule is 6 months from 2nd dose. However, for now, we will use an 8 week interval,
    ## to ensure that anyone having a third dose within the primary course (immunosuppressed, from 1st Sept)
    ## are not shown as due/missing a booster dose.
    ## however those with third doses will also eventually become eligible for booster so this may need to be revisited
    covid_vacc_third_dose_date=patients.with_tpp_vaccination_record(
        target_disease_matches="SARS-2 CORONAVIRUS",
        on_or_after="covid_vacc_second_dose_date + 56 days",
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {
                "earliest": "2021-09-24",  # first booster dose recorded
                "latest": "index_date",
            },
            "incidence": 0.1,
        },
    ),

    vaccination_primis_first_dose=patients.with_these_clinical_events(
        codelist=codelist(["1324681000000101"], system="snomed"),
        on_or_before="index_date",
        returning="binary_flag",
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        find_last_match_in_period=True,
        return_expectations={
            "category": {
                "ratios": generate_expectations_codes(["1324681000000101"])
            }
        },
    ),

    vaccination_primis_second_dose=patients.with_these_clinical_events(
        codelist=codelist(["1324691000000104"], system="snomed"),
        on_or_before="index_date",
        returning="binary_flag",
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        find_last_match_in_period=True,
        return_expectations={
            "category": {
                "ratios": generate_expectations_codes(["1324691000000104"])
            }
        },
    ),

    vaccination_primis_vaccination=patients.with_these_clinical_events(
        codelist=codelist(["840534001"], system="snomed"),
        on_or_before="index_date",
        returning="binary_flag",
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        find_last_match_in_period=True,
        return_expectations={
            "category": {
                "ratios": generate_expectations_codes(["840534001"])
            }
        },
    ),

    vaccination_primis_booster_dose=patients.with_these_clinical_events(
        codelist=codelist(["1362591000000103"], system="snomed"),
        on_or_before="index_date",
        returning="binary_flag",
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        find_last_match_in_period=True,
        return_expectations={
            "category": {
                "ratios": generate_expectations_codes(["1362591000000103"])
            }
        },
    ),
)





