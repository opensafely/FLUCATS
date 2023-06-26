test:
    PYTHONPATH=analysis/analysis python -m pytest

devenv:
    python -m venv venv
    venv/bin/activate
    pip install -r requirements.dev.txt

check:
    black --check analysis