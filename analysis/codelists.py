from cohortextractor import codelist_from_csv, codelist

ethnicity_opensafely = codelist_from_csv(
    "codelists/opensafely-ethnicity-snomed-0removed.csv",
    system="snomed",
    column="snomedcode",
    category_column="Grouping_16",
)

# Ethnicity codes
eth2001 = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-eth2001.csv",
    system="snomed",
    column="code",
    category_column="grouping_16_id",
)

# Any other ethnicity code
non_eth2001 = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-non_eth2001.csv",
    system="snomed",
    column="code",
)

# Ethnicity not given - patient refused
eth_notgiptref = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-eth_notgiptref.csv",
    system="snomed",
    column="code",
)

# Ethnicity not stated
eth_notstated = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-eth_notstated.csv",
    system="snomed",
    column="code",
)

# Ethnicity no record
eth_norecord = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-eth_norecord.csv",
    system="snomed",
    column="code",
)

eth_norecord = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-eth_norecord.csv",
    system="snomed",
    column="code",
)

emergency_hospital_admission_codelist = codelist_from_csv(
    "codelists/opensafely-alanine-aminotransferase-alt-tests.csv",
    system="snomed",
    column="code",
)

covid_death_codelist = codelist(["U071", "U072"], system="icd10")

addisons_hypoadrenalism_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-addis_cod.csv", system="snomed", column="code"
)

asthma_admission_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-astadm.csv",
    system="snomed",
    column="code",
)

asthma_diagnosis_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-ast.csv",
    system="snomed",
    column="code",
)

asthma_inhaler_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-astrxm1.csv",
    system="snomed",
    column="code",
)

asthma_steroid_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-astrxm2.csv",
    system="snomed",
    column="code",
)

bmi_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-bmi.csv", system="snomed", column="code"
)

chronic_heart_disease_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-chd_cov.csv", system="snomed", column="code"
)
chronic_respiratory_disease_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-resp_cov.csv", system="snomed", column="code"
)

primis_ckd_stage_codelist = codelist_from_csv(
    "codelists/ukrr-ckd-stages.csv",
    system="snomed",
    column="code",
    category_column="stage",
)

renal_disease_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-ckd_cov.csv", system="snomed", column="code"
)

ckd_os_codelist = codelist_from_csv(
    "codelists/opensafely-chronic-kidney-disease-snomed.csv", system="snomed", column="id"
)

liver_disease_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-cld.csv", system="snomed", column="code"
)

immunosuppression_disorder_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-immdx_cov.csv", system="snomed", column="code"
)

immunosuppression_medication_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-immrx.csv", system="snomed", column="code"
)

immunosuppression_chemo_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-dxt_chemo_cod.csv",
    system="snomed",
    column="code",
)

homeless_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-homeless_cod.csv",
    system="snomed",
    column="code",
)

type_of_residence_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-reside_cod.csv",
    system="snomed",
    column="code",
)

residential_care_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-longres.csv", system="snomed", column="code"
)

diabetes_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-diab.csv", system="snomed", column="code"
)

diabetes_resolved_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-dmres.csv", system="snomed", column="code"
)

gestational_diabetes_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-gdiab_cod.csv", system="snomed", column="code"
)

neurological_disorder_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-cns_cov.csv", system="snomed", column="code"
)

obesity_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-sev_obesity.csv",
    system="snomed",
    column="code",
)

hypertension_codelist = codelist_from_csv(
    "codelists/opensafely-hypertension-snomed.csv", system="snomed", column="id"
)

mental_illness_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-sev_mental.csv",
    system="snomed",
    column="code",
)


pregnancy_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-preg.csv", system="snomed", column="code"
)

pregnancy_or_delivery_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-pregdel.csv", system="snomed", column="code"
)

splenic_disease_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-spln_cov.csv", system="snomed", column="code"
)


statin_codelist = codelist_from_csv(
    "codelists/opensafely-statin-medication.csv", system="snomed", column="id"
)

flucats_pneumonia_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-pneumonia.csv", system="snomed", column="code"
)

flucats_icu_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-icu-admission.csv", system="snomed", column="code"
)

flucats_clinical_concern_note_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-clinical-concern-note.csv",
    system="snomed",
    column="code",
)

flucats_altered_consciousness_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-altered-conscious-level.csv",
    system="snomed",
    column="code",
)

flucats_causing_clinical_concern_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-causing-clinical-concern.csv",
    system="snomed",
    column="code",
)

flucats_dehydration_or_shock_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-evidence-of-dehydration-or-shock.csv",
    system="snomed",
    column="code",
)

flucats_dehydration_or_shock_observable_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-evidence-of-dehydration-or-shock-observable.csv",
    system="snomed",
    column="code",
)

flucats_increased_respiratory_rate_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-increased-respiratory-rate.csv",
    system="snomed",
    column="code",
)

flucats_increased_respiratory_rate_observable_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-increased-respiratory-rate-observable.csv",
    system="snomed",
    column="code",
)


flucats_oxygen_saturation_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-oxygen-saturation.csv",
    system="snomed",
    column="code",
)

flucats_oxygen_saturation_observable_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-oxygen-saturation-observable.csv",
    system="snomed",
    column="code",
)

flucats_respiratory_exhaustion_or_apnoea_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-respiratory-exhaustion-or-apnoea.csv",
    system="snomed",
    column="code",
)

flucats_severe_respiratory_distress_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-severe-respiratory-distress.csv",
    system="snomed",
    column="code",
)

flucats_blood_pressure_reading_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-blood-pressure-reading.csv",
    system="snomed",
    column="code",
)

flucats_who_performance_score_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-who-performance-score.csv",
    system="snomed",
    column="code",
)

flucats_heart_rate_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-heart-rate.csv",
    system="snomed",
    column="code",
)

flucats_heart_rate_observable_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-heart-rate-observable.csv",
    system="snomed",
    column="code",
)

flucats_temperature_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-temperature.csv",
    system="snomed",
    column="code",
)

flucats_temperature_observable_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-temperature-observable.csv",
    system="snomed",
    column="code",
)

flucats_hospital_admission_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-hospital-admissions.csv",
    system="snomed",
    column="code",
)

flucats_inspired_oxygen_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-inspired-oxygen.csv",
    system="snomed",
    column="code",
)

vaccination_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-covid-vaccination.csv", 
    system="snomed", 
    column="code",
)

second_dose_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-covid-vaccination-second-dose.csv",
    system="snomed",
    column="code",
)

booster_dose_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-covid-vaccination-booster.csv",
    system="snomed",
    column="code",
)

suspected_covid_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-covid-19-suspected-positive-test.csv",
    system="snomed",
    column="code",
)
probable_covid_codelist = codelist_from_csv(
    "codelists/user-Louis-flucats-covid-19-probable-positive-test.csv",
    system="snomed",
    column="code",
)



# First COVID vaccination administration codes
covadm1_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-covadm1.csv",
    system="snomed",
    column="code",
)

# Second COVID vaccination administration codes
covadm2_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-covadm2.csv",
    system="snomed",
    column="code",
)

# Pfizer BioNTech vaccination medication code
pfdrx_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-pfdrx.csv",
    system="snomed",
    column="code",
)

# Oxford AstraZeneca vaccination medication code
azdrx_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-azdrx.csv",
    system="snomed",
    column="code",
)

# Moderna vaccination medication code
modrx_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-modrx.csv",
    system="snomed",
    column="code",
)

# COVID vaccination medication codes
covrx_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-covrx.csv",
    system="snomed",
    column="code",
)

# High Risk from COVID-19 code
shield_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-shield.csv",
    system="snomed",
    column="code",
)

# Lower Risk from COVID-19 codes
nonshield_codelist = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-nonshield.csv",
    system="snomed",
    column="code",
)