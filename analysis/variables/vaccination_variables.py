from cohortextractor import patients
from codelists import *

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


     # First COVID vaccination administration codes
    covadm1_dat=patients.with_vaccination_record(
        returning="date",
        tpp={
            "target_disease_matches": "SARS-2 CORONAVIRUS",
        },
        emis={
            "procedure_codes": covadm1_codelist,
        },
        find_first_match_in_period=True,
        on_or_after="2020-11-29",
        date_format="YYYY-MM-DD",
    ),
    # Second COVID vaccination administration codes
    covadm2_dat=patients.with_vaccination_record(
        returning="date",
        tpp={
            "target_disease_matches": "SARS-2 CORONAVIRUS",
        },
        emis={
            "procedure_codes": covadm2_codelist,
        },
        find_last_match_in_period=True,
        on_or_after="covadm1_dat + 19 days",
        date_format="YYYY-MM-DD",
    ),
    # First Pfizer BioNTech vaccination medication code
    pfd1rx_dat=patients.with_vaccination_record(
        returning="date",
        tpp={
            "product_name_matches": "COVID-19 mRNA Vac BNT162b2 30mcg/0.3ml conc for susp for inj multidose vials (Pfizer-BioNTech)",
        },
        emis={
            "product_codes": pfdrx_codelist,
        },
        find_first_match_in_period=True,
        on_or_after="2020-11-29",
        date_format="YYYY-MM-DD",
    ),
    # Second Pfizer BioNTech vaccination medication code
    pfd2rx_dat=patients.with_vaccination_record(
        returning="date",
        tpp={
            "product_name_matches": "COVID-19 mRNA Vac BNT162b2 30mcg/0.3ml conc for susp for inj multidose vials (Pfizer-BioNTech)",
        },
        emis={
            "product_codes": pfdrx_codelist,
        },
        find_last_match_in_period=True,
        on_or_after="pfd1rx_dat + 19 days",
        date_format="YYYY-MM-DD",
    ),
    # First Oxford AstraZeneca vaccination medication code
    azd1rx_dat=patients.with_vaccination_record(
        returning="date",
        tpp={
            "product_name_matches": "COVID-19 Vac AstraZeneca (ChAdOx1 S recomb) 5x10000000000 viral particles/0.5ml dose sol for inj MDV",
        },
        emis={
            "product_codes": azdrx_codelist,
        },
        find_first_match_in_period=True,
        on_or_after="2020-11-29",
        date_format="YYYY-MM-DD",
    ),
    # Second Oxford AstraZeneca vaccination medication code
    azd2rx_dat=patients.with_vaccination_record(
        returning="date",
        tpp={
            "product_name_matches": "COVID-19 Vac AstraZeneca (ChAdOx1 S recomb) 5x10000000000 viral particles/0.5ml dose sol for inj MDV",
        },
        emis={
            "product_codes": azdrx_codelist,
        },
        find_last_match_in_period=True,
        on_or_after="azd1rx_dat + 19 days",
        date_format="YYYY-MM-DD",
    ),
    # First COVID vaccination medication code (any)
    covrx1_dat=patients.with_vaccination_record(
        returning="date",
        tpp={
            "product_name_matches": [
                "COVID-19 mRNA Vac BNT162b2 30mcg/0.3ml conc for susp for inj multidose vials (Pfizer-BioNTech)",
                "COVID-19 Vac AstraZeneca (ChAdOx1 S recomb) 5x10000000000 viral particles/0.5ml dose sol for inj MDV",
            ],
        },
        emis={
            "product_codes": covrx_codelist,
        },
        find_first_match_in_period=True,
        on_or_after="2020-11-29",
        date_format="YYYY-MM-DD",
    ),
    # Second COVID vaccination medication code (any)
    covrx2_dat=patients.with_vaccination_record(
        returning="date",
        tpp={
            "product_name_matches": [
                "COVID-19 mRNA Vac BNT162b2 30mcg/0.3ml conc for susp for inj multidose vials (Pfizer-BioNTech)",
                "COVID-19 Vac AstraZeneca (ChAdOx1 S recomb) 5x10000000000 viral particles/0.5ml dose sol for inj MDV",
            ],
        },
        emis={
            "product_codes": covrx_codelist,
        },
        find_last_match_in_period=True,
        on_or_after="covrx1_dat + 19 days",
        date_format="YYYY-MM-DD",
    ),

     # First COVID vaccination administration codes
    covadm1=patients.with_vaccination_record(
        returning="binary_flag",
        tpp={
            "target_disease_matches": "SARS-2 CORONAVIRUS",
        },
        emis={
            "procedure_codes": covadm1_codelist,
        },
        find_first_match_in_period=True,
        on_or_after="2020-11-29",
    ),
    # Second COVID vaccination administration codes
    covadm2=patients.with_vaccination_record(
        returning="binary_flag",
        tpp={
            "target_disease_matches": "SARS-2 CORONAVIRUS",
        },
        emis={
            "procedure_codes": covadm2_codelist,
        },
        find_last_match_in_period=True,
        on_or_after="covadm1_dat + 19 days",
    ),
    # First Pfizer BioNTech vaccination medication code
    pfd1rx=patients.with_vaccination_record(
        returning="binary_flag",
        tpp={
            "product_name_matches": "COVID-19 mRNA Vac BNT162b2 30mcg/0.3ml conc for susp for inj multidose vials (Pfizer-BioNTech)",
        },
        emis={
            "product_codes": pfdrx_codelist,
        },
        find_first_match_in_period=True,
        on_or_after="2020-11-29",
    ),
    # Second Pfizer BioNTech vaccination medication code
    pfd2rx=patients.with_vaccination_record(
        returning="binary_flag",
        tpp={
            "product_name_matches": "COVID-19 mRNA Vac BNT162b2 30mcg/0.3ml conc for susp for inj multidose vials (Pfizer-BioNTech)",
        },
        emis={
            "product_codes": pfdrx_codelist,
        },
        find_last_match_in_period=True,
        on_or_after="pfd1rx_dat + 19 days",
    ),
    # First Oxford AstraZeneca vaccination medication code
    azd1rx=patients.with_vaccination_record(
        returning="binary_flag",
        tpp={
            "product_name_matches": "COVID-19 Vac AstraZeneca (ChAdOx1 S recomb) 5x10000000000 viral particles/0.5ml dose sol for inj MDV",
        },
        emis={
            "product_codes": azdrx_codelist,
        },
        find_first_match_in_period=True,
        on_or_after="2020-11-29",
    ),
    # Second Oxford AstraZeneca vaccination medication code
    azd2rx=patients.with_vaccination_record(
        returning="binary_flag",
        tpp={
            "product_name_matches": "COVID-19 Vac AstraZeneca (ChAdOx1 S recomb) 5x10000000000 viral particles/0.5ml dose sol for inj MDV",
        },
        emis={
            "product_codes": azdrx_codelist,
        },
        find_last_match_in_period=True,
        on_or_after="azd1rx_dat + 19 days",
    ),
    # First COVID vaccination medication code (any)
    covrx1=patients.with_vaccination_record(
        returning="binary_flag",
        tpp={
            "product_name_matches": [
                "COVID-19 mRNA Vac BNT162b2 30mcg/0.3ml conc for susp for inj multidose vials (Pfizer-BioNTech)",
                "COVID-19 Vac AstraZeneca (ChAdOx1 S recomb) 5x10000000000 viral particles/0.5ml dose sol for inj MDV",
            ],
        },
        emis={
            "product_codes": covrx_codelist,
        },
        find_first_match_in_period=True,
        on_or_after="2020-11-29",
    ),
    # Second COVID vaccination medication code (any)
    covrx2=patients.with_vaccination_record(
        returning="binary_flag",
        tpp={
            "product_name_matches": [
                "COVID-19 mRNA Vac BNT162b2 30mcg/0.3ml conc for susp for inj multidose vials (Pfizer-BioNTech)",
                "COVID-19 Vac AstraZeneca (ChAdOx1 S recomb) 5x10000000000 viral particles/0.5ml dose sol for inj MDV",
            ],
        },
        emis={
            "product_codes": covrx_codelist,
        },
        find_last_match_in_period=True,
        on_or_after="covrx1_dat + 19 days",
    ),

    

)
