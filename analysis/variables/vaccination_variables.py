from cohortextractor import patients
from codelists import *

vaccination_variables = dict(
    
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
