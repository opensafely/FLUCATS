from cohortextractor import StudyDefinition, patients, codelist



study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.5,
    },
    population=patients.all(),
    flucats_template=patients.with_these_clinical_events(
        codelist=codelist(["13044541000006109"], system="snomed"),
        on_or_before="2021-06-30",
        returning="binary_flag",
        find_last_match_in_period=True,
        return_expectations={"incidence": 0.5},
    ),
    died=patients.with_death_recorded_in_primary_care(
        on_or_after="2021-06-30",
        returning="binary_flag",
    ),

)
