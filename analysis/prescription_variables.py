from cohortextractor import patients
from codelists import *

prescription_variables = dict(

    steroids = patients.with_these_medications(
        steroid_codelist,
        between=["index_date - 6 months", "index_date"],
        returning="binary_flag",
    ),
    antibiotics = patients.with_these_medications(
        antibiotic_codelist,
        between=["index_date - 6 months", "index_date"],
        returning="binary_flag",
    ),
    antivirals = patients.with_these_medications(
        antiviral_codelist,
        between=["index_date - 6 months", "index_date"],
        returning="binary_flag",
    ),
    statins = patients.with_these_medications(
        statin_codelist,
        between=["index_date - 6 months", "index_date"],
        returning="binary_flag",
    )

)