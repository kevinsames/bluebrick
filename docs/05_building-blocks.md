# 05. Building Blocks View (Project Structure)

The repository is structured into clear components to separate different concerns of the ML workflow. At a high level, it consists of folders for infrastructure, application code/notebooks, tests, pipelines, and documentation, along with configuration files for environment and tooling. Below is the top-level structure with key contents:

- **/infra** – Infrastructure-as-Code resources.  
  Contains Terraform code to provision and configure Azure resources and Databricks workspace setup. Example files:
  - `main.tf` and related `.tf` files define resources like the Azure Databricks workspace (SKU, pricing tier, VNet injection if needed), the Azure Storage account (ADLS Gen2), and Azure AD applications or service principals for Databricks to access storage.
  - Sets up IAM roles (e.g., Blob Data Contributor) for secure access.
  - May use the Databricks Terraform provider to configure workspace-level items (secret scopes, mount points, Unity Catalog metastore, etc.).
  - Organized modularly (subfolders/modules for networking, data lake, databricks). Includes variables and outputs for customization.

- **/src** – Source code for reusable Python modules and Spark jobs.  
  A Python package (installable with `setup.py` or `pyproject.toml`) containing the core logic for data processing and ML. Example modules:
  - `data_ingestion.py` – functions to read raw data from ADLS.
  - `feature_engineering.py` – transformations using PySpark or pandas.
  - `train_model.py` – model training logic, logs metrics to MLflow.
  - `evaluate.py` – model evaluation code.
  - `common.py` or `utils/` – shared helpers (e.g., config, Spark session).
  - Organized for easy import in notebooks and jobs.

- **/notebooks** – Databricks notebooks for interactive analysis or orchestration.  
  Importable to Databricks as `.py` or `.ipynb`. Example notebooks:
  - Data exploration (e.g., `01_explore_data.py`)
  - Data prep & feature engineering (`02_prepare_data.py`)
  - Model training (`03_train_model.py`)
  - Model evaluation/inference (`04_batch_inference.py`)
  - Orchestration notebook (optional)
  - Notebooks are focused, delegate logic to `/src`, and are annotated for clarity.

- **/tests** – Test suite for code and workflows (using pytest).  
  - Unit tests for Python modules in `/src`.
  - Integration tests for pipeline components or notebooks.
  - Spark testing setup (e.g., `conftest.py` for Spark session fixture).
  - Test dependencies listed in `requirements.txt` or `dev-requirements.txt`.

- **/docs** – Project documentation.  
  - `README.md`: Overview, quick start, setup instructions.
  - arc42 architecture docs: Split into multiple markdown files (covering all arc42 sections), with diagrams (PlantUML/Mermaid).
  - Architecture diagrams: Deployment, workflow, and sequence diagrams.
  - Documentation tooling (optional): MkDocs or Sphinx config for publishing docs.

- **/pipelines** – CI/CD pipeline definitions (GitHub Actions workflows).  
  - Example YAML workflow files for build/test, notebook validation, infra deployment, Databricks deployment, and (optionally) MLflow model deployment.
  - Secrets referenced via `${{ secrets.NAME }}`.
  - Produces artifacts for troubleshooting.

- **Other Files (Configuration & Meta):**
  - `requirements.txt`: Python dependencies.
  - `setup.py` or `pyproject.toml`: Makes `/src` pip-installable.
  - `.pre-commit-config.yaml`: Pre-commit hooks (black, flake8, isort, etc.).
  - `.gitignore`: Standard ignores for Python, notebooks, Terraform, IDE files.
  - `LICENSE`: Open-source license (e.g., Apache 2.0).
  - `CONTRIBUTING.md`: Contribution guidelines.
  - Issue/PR templates: For systematic project maintenance.

This structure modularizes the project into clear building blocks: Infrastructure, Code/Notebooks, CI/CD, and Documentation. Each block is relatively independent, enabling teams to work in parallel and maintain a coherent, production-ready ML project.