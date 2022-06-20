from cohortextractor import patients
from codelists import *

comorbidity_variables = dict(
    bmi=patients.most_recent_bmi(
        on_or_before="index_date",
        include_measurement_date=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2010-02-01", "latest": "2022-04-01"},
            "float": {"distribution": "normal", "mean": 28, "stddev": 8},
            "incidence": 0.8,
        }
    ),

    asthma=patients.with_these_clinical_events(
        asthma_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
    ),

    chronic_heart_disease=patients.with_these_clinical_events(
        chronic_heart_disease_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
    ),

    chronic_respiratory_disease=patients.with_these_clinical_events(
        chronic_respiratory_disease_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
    ),

    renal_disease=patients.with_these_clinical_events(
        renal_disease_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
    ),

    liver_disease=patients.with_these_clinical_events(
        liver_disease_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
    ),

    diabetes=patients.with_these_clinical_events(
        diabetes_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
    ),

    neurological_disorder=patients.with_these_clinical_events(
        neurological_disorder_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
    ),

    hypertension=patients.with_these_clinical_events(
        hypertension_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
    ),

    pregnancy=patients.with_these_clinical_events(
        pregnancy_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
    ),

    immunosuppression_disorder=patients.with_these_clinical_events(
        immunosuppression_disorder_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
    ),

    immunosuppression_chemo=patients.with_these_clinical_events(
        immunosuppression_chemo_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
    ),
    immunosuppression_medication=patients.with_these_medications(
        immunosuppression_medication_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
    ),

    )

