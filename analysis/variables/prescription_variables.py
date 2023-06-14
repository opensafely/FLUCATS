from cohortextractor import patients
from codelists import *

prescription_variables = dict(
    statins=patients.with_these_medications(
        statin_codelist,
        between=["index_date - 180 days", "index_date"],
        returning="binary_flag",
        return_expectations={
            "incidence": 0.05,
        },
    )
)
