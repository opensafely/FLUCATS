from cohortextractor import patients
from codelists import *

prescription_variables = dict(

    steroids = patients.with_these_medications(
        steroid_codelist,
        between=["index_date - 180 days", "index_date"],
        returning="binary_flag",
        return_expectations={
            "incidence": 0.05,
        },
    ),
    antibiotics = patients.with_these_medications(
        antibiotic_codelist,
        between=["index_date - 180 days", "index_date"],
        returning="binary_flag",
        return_expectations={
            "incidence": 0.05,
        },
    ),
    antivirals = patients.with_these_medications(
        antiviral_codelist,
        between=["index_date - 180 days", "index_date"],
        returning="binary_flag",
        return_expectations={
            "incidence": 0.05,
        },
    ),
    statins = patients.with_these_medications(
        statin_codelist,
        between=["index_date - 180 days", "index_date"],
        returning="binary_flag",
        return_expectations={
            "incidence": 0.05,
        },
    )

)