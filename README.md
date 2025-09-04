BlueBrick — Azure Databricks Template
====================================

Production‑ready template for Azure Databricks with Terraform IaC and GitHub Actions CI/CD. It includes Unity Catalog‑ready notebooks/jobs via Databricks Asset Bundles, optional Azure Data Factory for ingestion, and optional hub‑and‑spoke networking.

Docs
----
- Start here: `docs/index.md`
- Quickstart: `docs/quickstart.md`
- Architecture (Hub/Spoke + Coal/Bronze/Silver/Gold): `docs/architecture.md`
- Infrastructure (Terraform): `docs/infrastructure.md`
- CI/CD Workflows: `docs/ci-cd.md`
- Databricks (Bundles, UC): `docs/databricks.md`
- Data Factory: `docs/data-factory.md`
- Configuration and secrets: `docs/configuration.md`
- Local development: `docs/local-dev.md`
- Troubleshooting: `docs/troubleshooting.md`

What’s Inside
-------------
- IaC: `infrastructure/terraform/` (RG, ADLS Gen2 `coal` landing container, Databricks workspace, optional hub/spoke, ADF, UC examples)
- Code: `src/` (package + notebooks) and `configs/` (env YAML)
- Databricks bundle: `databricks.yml`
- ADF Git root (dev authoring): `data-factory/` (excluded from pre‑commit)
- Workflows: `.github/workflows/`

Workflows (CI/CD)
-----------------
- `ci.yml`: lint (Ruff), format check (Black), tests (pytest)
- `deploy-azure-envs.yml`: manual; deploy Terraform to `hub|dev|test|prod`
- `deploy-data-factory.yml`: manual; deploy only ADF (dev links to `data-factory/`)
- `deploy-databricks-dev.yml`: on `main` when `src/**` changes; deploy bundle to `dev` and run job
- `deploy-databricks.yml`: on tag or release; deploy bundle to `release` (uses tag as source)

Prereqs
-------
- Python 3.10+ and JDK 11
- Databricks CLI auth: `DATABRICKS_HOST`, `DATABRICKS_TOKEN`
- Azure OIDC creds and subscription IDs (see `docs/configuration.md`)

Quickstart (1–2 mins overview)
------------------------------
1) Create a venv and install deps: `python -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt`
2) Add GitHub secrets (Azure + Databricks; multi‑sub IDs if used)
3) Run “Deploy Azure (Hub/Envs)” for `dev` (apply=true)
4) Push changes under `src/**` or trigger “Deploy Databricks (dev)”
5) Check the `bluebrick-quickstart` job and verify UC table output

License
-------
MIT — see `LICENSE`.

