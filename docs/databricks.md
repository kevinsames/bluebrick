# Databricks

This template uses Databricks Asset Bundles for deployments and Unity Catalog for table governance.

## Bundles

- Bundle file: `databricks.yml`
- Targets:
  - `dev`: sources code from the `main` branch
  - `release`: sources code from the Git tag (`GIT_TAG`)
- Jobs:
  - `bluebrick-quickstart`: runs the notebook `src/notebooks/00_quickstart_etl.ipynb`

## Workflows

- Dev: `.github/workflows/deploy-databricks-dev.yml` (push to `src/**`)
- Release: `.github/workflows/deploy-databricks.yml` (tags/releases)

## Unity Catalog

- Bronze/Silver/Gold are modeled as UC managed Delta tables
- Create per‑use‑case schemas in Gold and grant read/write as per interface contracts

## Running locally

- Start Jupyter: `jupyter notebook`
- Open `src/notebooks/00_quickstart_etl.ipynb`
- Ensure Java 11 is installed and `JAVA_HOME` is set

