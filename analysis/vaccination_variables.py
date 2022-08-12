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
    # COVID VACCINATION - Pfizer BioNTech
    covid_vacc_pfizer_date=patients.with_tpp_vaccination_record(
        product_name_matches="COVID-19 mRNA Vaccine Comirnaty 30micrograms/0.3ml dose conc for susp for inj MDV (Pfizer)",
        on_or_after="2020-12-01",  # check all december to date
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {
                "earliest": "2020-12-08",  # first vaccine administered on the 8/12
                "latest": "index_date",
            },
            "incidence": 0.7,
        },
    ),
    # COVID VACCINATION - Oxford AZ
    covid_vacc_oxford_date=patients.with_tpp_vaccination_record(
        product_name_matches="COVID-19 Vaccine Vaxzevria 0.5ml inj multidose vials (AstraZeneca)",
        on_or_after="2020-12-01",  # check all december to date
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {
                "earliest": "2020-01-04",  # first vaccine administered on the 4/1
                "latest": "index_date",
            },
            "incidence": 0.7,
        },
    ),
    # COVID VACCINATION - Moderna
    covid_vacc_moderna_date=patients.with_tpp_vaccination_record(
        product_name_matches="COVID-19 mRNA Vaccine Spikevax (nucleoside modified) 0.1mg/0.5mL dose disp for inj MDV (Moderna)",
        on_or_after="2020-12-01",  # check all december to date
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {
                "earliest": "2020-04-01",  # expected from early april
                "latest": "index_date",
            },
            "incidence": 0.4,
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
    # COVID VACCINATION - Pfizer BioNTech
    covid_vacc_second_dose_pfizer_date=patients.with_tpp_vaccination_record(
        product_name_matches="COVID-19 mRNA Vaccine Comirnaty 30micrograms/0.3ml dose conc for susp for inj MDV (Pfizer)",
        on_or_after="covid_vacc_date + 19 days",  # check all december to date
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {
                "earliest": "2020-12-08",  # first vaccine administered on the 8/12
                "latest": "index_date",
            },
            "incidence": 0.7,
        },
    ),
    # COVID VACCINATION - Oxford AZ
    covid_vacc_second_dose_oxford_date=patients.with_tpp_vaccination_record(
        product_name_matches="COVID-19 Vaccine Vaxzevria 0.5ml inj multidose vials (AstraZeneca)",
        on_or_after="covid_vacc_date + 19 days",  # check all december to date
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {
                "earliest": "2020-01-04",  # first vaccine administered on the 4/1
                "latest": "index_date",
            },
            "incidence": 0.7,
        },
    ),
    # COVID VACCINATION - Moderna
    covid_vacc_second_dose_moderna_date=patients.with_tpp_vaccination_record(
        product_name_matches="COVID-19 mRNA Vaccine Spikevax (nucleoside modified) 0.1mg/0.5mL dose disp for inj MDV (Moderna)",
        on_or_after="covid_vacc_date + 19 days",  # check all december to date
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {
                "earliest": "2020-04-01",  # expected from early april
                "latest": "index_date",
            },
            "incidence": 0.4,
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
    ## BRAND OF THIRD/BOOSTER DOSES
    # BOOSTER (3rd) DOSE COVID VACCINATION - Pfizer
    covid_vacc_third_dose_pfizer_date=patients.with_tpp_vaccination_record(
        product_name_matches="COVID-19 mRNA Vaccine Comirnaty 30micrograms/0.3ml dose conc for susp for inj MDV (Pfizer)",
        on_or_after="covid_vacc_second_dose_date + 56 days",
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {
                "earliest": "2021-09-24",  # first booster dose recorded
                "latest": "index_date",
            },
            "incidence": 0.25,
        },
    ),
    # BOOSTER (3rd) DOSE COVID VACCINATION - Oxford AZ
    covid_vacc_third_dose_oxford_date=patients.with_tpp_vaccination_record(
        product_name_matches="COVID-19 Vaccine Vaxzevria 0.5ml inj multidose vials (AstraZeneca)",
        on_or_after="covid_vacc_second_dose_date + 56 days",
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {
                "earliest": "2021-09-24",  # first booster dose recorded
                "latest": "index_date",
            },
            "incidence": 0.10,
        },
    ),
    # BOOSTER (3rd) DOSE COVID VACCINATION - Moderna
    covid_vacc_third_dose_moderna_date=patients.with_tpp_vaccination_record(
        product_name_matches="COVID-19 mRNA Vaccine Spikevax (nucleoside modified) 0.1mg/0.5mL dose disp for inj MDV (Moderna)",
        on_or_after="covid_vacc_second_dose_date + 56 days",
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {
                "earliest": "2021-09-24",  # first booster dose recorded
                "latest": "index_date",
            },
            "incidence": 0.25,
        },
    ),
)
