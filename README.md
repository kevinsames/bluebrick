# Azure Databricks ML Template Repository

## 🚀 Overview
This repository provides a production-grade, enterprise-ready template for **Machine Learning (ML), Data Science, and Data Engineering projects** using **Azure Databricks** as the core compute engine. It is designed for **data scientists** and **ML engineers**, and adheres to software engineering best practices (modularity, CI/CD, versioning, testing) with full documentation using the **arc42 architecture framework**.

## 🧱 Tech Stack
- **Azure Databricks** (Asset Bundles, Notebooks, Jobs, MLflow)
- **Azure Data Lake Storage Gen2**
- **Terraform** for Infrastructure-as-Code
- **GitHub Actions** for CI/CD
- **Python** (PySpark, pandas, scikit-learn, MLflow)
- **Optional**: Unity Catalog, Great Expectations, MkDocs

## 📁 Project Structure
```
.
├── infra/                     # Terraform scripts for Azure + Databricks
├── src/                      # Python modules (ETL, ML, utils)
├── notebooks/                # Databricks notebooks
├── tests/                    # Pytest-based unit/integration tests
├── pipelines/                # GitHub Actions YAML workflows
├── docs/                     # arc42-based architecture documentation
│   ├── arc42-01_introduction.md
│   └── ...
├── requirements.txt          # Python dependencies
├── setup.py                  # Project installer
├── .pre-commit-config.yaml   # Code linting/formatting hooks
├── LICENSE
├── CONTRIBUTING.md
└── README.md
```

## ⚙️ Quickstart
### 1. Prerequisites
- Azure Subscription with Databricks enabled
- Terraform CLI & Azure CLI
- GitHub account + secrets for CI/CD
- Databricks CLI v0.205+ with Asset Bundles support

### 2. Setup
```bash
# Clone the repository
$ git clone <your-fork-url>
$ cd azure-databricks-ml-template

# Initialize Terraform
$ cd infra && terraform init

# Apply Terraform to deploy infra (dev environment)
$ terraform apply -var-file=dev.tfvars

# Authenticate Databricks CLI
$ databricks auth login --host <workspace-url>

# Deploy Asset Bundle
$ cd ..
$ databricks bundle deploy
```

### 3. Run Example Notebook
Use the Databricks UI or CLI to run the example training notebook and track results in MLflow.

### 4. CI/CD via GitHub Actions
- Lint, test, deploy notebooks/jobs
- Triggered on PRs, merges, and tags

## 🧪 Features
- ✅ Modular Python and Notebook codebase
- ✅ MLflow experiment tracking & model registry
- ✅ Example: NYC Taxi dataset pipeline
- ✅ Job orchestration & scheduling
- ✅ Data validation with Great Expectations
- ✅ Unity Catalog integration (optional)
- ✅ Full arc42 documentation with diagrams

## 📚 Documentation
Architecture docs are under `/docs/` using arc42:
- 01 Introduction and Goals
- 02 Architecture Constraints
- 03 Context & Scope
- ...
- 12 Glossary

For HTML docs:
```bash
# Serve using mkdocs
$ pip install mkdocs-material
$ mkdocs serve
```

## 🤝 Contributing
We welcome contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📜 License
Apache 2.0 – see [LICENSE](LICENSE)

## 🧠 Credits
Inspired by best practices from:
- Databricks MLOps Stack
- Azure CAF
- arc42 Architecture Template
- GitHub Template Repositories

---

**Start fast. Scale with confidence. Audit with ease.**
