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
        },
    ),
    bmi_primis=patients.with_these_clinical_events(
        bmi_codelist,
        on_or_before="index_date",
        returning="numeric_value",
        find_last_match_in_period=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 28, "stddev": 8},
            "incidence": 0.8,
        },
    ),
    ### Patients with Asthma
    asthma=patients.satisfying(
        """
        ASTADM
        OR
        (
        AST
        AND
        ASTRXM1
        AND
        ASTRXM2 > 1
        )
        """,
        ### Asthma Admission codes
        ASTADM=patients.with_these_clinical_events(
            asthma_admission_codelist,
            find_last_match_in_period=True,
            between=["index_date - 730 days", "index_date"],
        ),
        ### Asthma Diagnosis code
        AST=patients.with_these_clinical_events(
            asthma_diagnosis_codelist,
            find_first_match_in_period=True,
            on_or_before="index_date",
        ),
        ### Asthma - inhalers in last 12 months
        ASTRXM1=patients.with_these_medications(
            asthma_inhaler_codelist,
            returning="binary_flag",
            between=["index_date - 365 days", "index_date"],
        ),
        ### Asthma - systemic oral steroid prescription codes in last 24 months
        ASTRXM2=patients.with_these_medications(
            asthma_steroid_codelist,
            returning="number_of_matches_in_period",
            between=["index_date - 730 days", "index_date"],
        ),
        return_expectations={
            "incidence": 0.05,
        },
    ),
    addisons_hypoadrenalism=patients.with_these_clinical_events(
        addisons_hypoadrenalism_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
        return_expectations={
            "incidence": 0.01,
        },
    ),
    chronic_heart_disease=patients.with_these_clinical_events(
        chronic_heart_disease_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
        return_expectations={
            "incidence": 0.05,
        },
    ),
    chronic_respiratory_disease=patients.with_these_clinical_events(
        chronic_respiratory_disease_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
        return_expectations={
            "incidence": 0.05,
        },
    ),
    chronic_kidney_disease=patients.with_these_clinical_events(
        chronic_kidney_disease_non_stage_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
        return_expectations={
            "incidence": 0.05,
        },
    ),
    renal_disease=patients.with_these_clinical_events(
        renal_disease_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
        return_expectations={
            "incidence": 0.05,
        },
    ),
    liver_disease=patients.with_these_clinical_events(
        liver_disease_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
        return_expectations={
            "incidence": 0.05,
        },
    ),
    ### Patients who are currently pregnant - https://github.com/opensafely/covid-vaccine-preliminary-uptake-study/analysis/study_definition_delivery_u16.py
    pregnant=patients.satisfying(
        """
        PREG
        AND
        PREG_DAT
        AND
        PREGDEL_DAT < PREG_DAT
        """,
        ### Pregnancy codes recorded in the 8.5 months before the audit run date
        PREG=patients.with_these_clinical_events(
            pregnancy_codelist,
            returning="binary_flag",
            between=["index_date - 254 days", "index_date"],
        ),
        ### Pregnancy or Delivery codes recorded in the 8.5 months before audit run date
        PREGDEL_DAT=patients.with_these_clinical_events(
            pregnancy_or_delivery_codelist,
            returning="date",
            find_last_match_in_period=True,
            between=["index_date - 254 days", "index_date"],
            date_format="YYYY-MM-DD",
        ),
        ### Date of pregnancy codes recorded in the 8.5 months before audit run date
        PREG_DAT=patients.with_these_clinical_events(
            pregnancy_codelist,
            returning="date",
            find_last_match_in_period=True,
            between=["index_date - 254 days", "index_date"],
            date_format="YYYY-MM-DD",
        ),
        return_expectations={
            "incidence": 0.05,
        },
    ),
    ### Patients with Diabetes
    diabetes=patients.satisfying(
        """
        (
            DIAB_DAT
            AND
            DIAB_DAT > nulldate
            AND
            DIAB_DAT > DMRES_DAT
        )
        
        """,
        
        ### Date any Diabetes diagnosis Read code is recorded
        DIAB_DAT=patients.with_these_clinical_events(
            diabetes_codelist,
            returning="date",
            find_last_match_in_period=True,
            on_or_before="index_date",
            date_format="YYYY-MM-DD",
        ),
        ### Date of Diabetes resolved codes
        DMRES_DAT=patients.with_these_clinical_events(
            diabetes_resolved_codelist,
            returning="date",
            find_last_match_in_period=True,
            on_or_before="index_date",
            date_format="YYYY-MM-DD",
        ),
        nulldate=patients.fixed_value("1900-01-01"),
        return_expectations={
            "incidence": 0.05,
        },
    ),
    ### Patients who are currently pregnant with gestational diabetes
    gestational_diabetes=patients.satisfying(
        """
        GDIAB
        AND
        pregnant
        """,
        ### Gestational Diabetes diagnosis codes
        GDIAB=patients.with_these_clinical_events(
            gestational_diabetes_codelist,
            find_last_match_in_period=True,
            returning="binary_flag",
            between=["index_date - 254 days", "index_date"],
        ),
        return_expectations={
            "incidence": 0.01,
        },
    ),
    obesity=patients.with_these_clinical_events(
        obesity_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
        return_expectations={
            "incidence": 0.05,
        },
    ),
    mental_illness=patients.with_these_clinical_events(
        mental_illness_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
        return_expectations={
            "incidence": 0.05,
        },
    ),
    neurological_disorder=patients.with_these_clinical_events(
        neurological_disorder_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
        return_expectations={
            "incidence": 0.05,
        },
    ),
    hypertension=patients.with_these_clinical_events(
        hypertension_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
        return_expectations={
            "incidence": 0.05,
        },
    ),
    pneumonia=patients.with_these_clinical_events(
        flucats_pneumonia_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
        return_expectations={
            "incidence": 0.05,
        },
    ),
    immunosuppression_disorder=patients.with_these_clinical_events(
        immunosuppression_disorder_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
        return_expectations={
            "incidence": 0.05,
        },
    ),
    immunosuppression_chemo=patients.with_these_clinical_events(
        immunosuppression_chemo_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
        return_expectations={
            "incidence": 0.05,
        },
    ),
    immunosuppression_medication=patients.with_these_medications(
        immunosuppression_medication_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
        return_expectations={
            "incidence": 0.05,
        },
    ),
    splenic_disease=patients.with_these_clinical_events(
        splenic_disease_codelist,
        on_or_before="index_date",
        find_last_match_in_period=True,
        returning="binary_flag",
        return_expectations={
            "incidence": 0.05,
        },
    ),
)
