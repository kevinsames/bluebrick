# BlueBrick Documentation

Welcome to the BlueBrick docs. This hub links to the most useful topics for getting started, understanding the architecture, and operating the template in CI/CD.

- Quickstart: end‑to‑end in under 30 minutes
  - See: [quickstart.md](quickstart.md)
- Architecture: hub/spoke networking + data layers (Coal/Bronze/Silver/Gold)
  - See: [architecture.md](architecture.md)
- Infrastructure as Code (Terraform)
  - See: [infrastructure.md](infrastructure.md)
- CI/CD Workflows (GitHub Actions)
  - See: [ci-cd.md](ci-cd.md)
- Databricks (Bundles, jobs, UC)
  - See: [databricks.md](databricks.md)
- Azure Data Factory (ADF)
  - See: [data-factory.md](data-factory.md)
- Configuration (YAML/env/secrets)
  - See: [configuration.md](configuration.md)
- Local development (venv, JDK, lint/test)
  - See: [local-dev.md](local-dev.md)
- Troubleshooting (common issues)
  - See: [troubleshooting.md](troubleshooting.md)

## Repo map

- Root README: high‑level intro and quick links
- `infrastructure/terraform`: IaC for Azure + Databricks + optional networking and ADF
- `src/`: package code and notebooks
- `configs/`: per‑environment YAML config
- `data-factory/`: ADF Git root for dev authoring

