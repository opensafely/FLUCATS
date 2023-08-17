from cohortextractor import patients
from codelists import vaccination_codelist, second_dose_codelist, booster_dose_codelist

vaccination_variables = dict(
    first_vaccination=patients.with_these_clinical_events(
        vaccination_codelist,
        between=["2020-12-01", "2021-06-30"],
        returning="binary_flag",
        find_first_match_in_period=True,
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "incidence": 0.8,
        },
    ),
    second_vaccination=patients.with_these_clinical_events(
        vaccination_codelist,
        between=["first_vaccination_date + 19 days", "2021-06-30"],
        returning="binary_flag",
        find_first_match_in_period=True,
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "incidence": 0.8,
        },
    ),
    coded_second_vaccination=patients.with_these_clinical_events(
        second_dose_codelist,
        between=["2020-12-01", "2021-06-30"],
        returning="binary_flag",
        find_first_match_in_period=True,
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "incidence": 0.8,
        },
    ),
    booster_vaccination=patients.with_these_clinical_events(
        vaccination_codelist,
        between=["second_vaccination_date + 56 days", "2021-06-30"],
        returning="binary_flag",
        find_first_match_in_period=True,
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "incidence": 0.8,
        },
    ),
    coded_booster_vaccination=patients.with_these_clinical_events(
        booster_dose_codelist,
        between=["2020-12-01", "2021-06-30"],
        returning="binary_flag",
        find_first_match_in_period=True,
        include_date_of_match=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "incidence": 0.8,
        },
    ),
    has_second_dose = patients.satisfying(
        """
        second_vaccination OR
        coded_second_vaccination
        """,
    ),
    has_booster_dose = patients.satisfying(
        """
        booster_vaccination OR
        coded_booster_vaccination
        """,
    ),

)
