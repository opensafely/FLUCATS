def generate_expectations_codes(codelist, incidence=0.5):
    expectations = {str(x): (1 - incidence) / len(codelist) for x in codelist}
    expectations[None] = incidence
    return expectations
