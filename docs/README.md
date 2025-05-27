# 📚 arc42 Documentation

## 01_introduction.md
```markdown
# 01. Introduction and Goals
This template supports ML/data science workflows on Azure using Databricks, ADLS Gen2, and Terraform. It enables reproducible, secure, and scalable ML pipelines with tracking, governance, and CI/CD.
```

## 02_constraints.md
```markdown
# 02. Architecture Constraints
- Azure cloud platform only
- Use of Terraform and GitHub Actions
- Only Databricks and ADLS Gen2 supported for compute/storage
- Python-based development with PySpark, scikit-learn
```

## 03_context.md
```markdown
# 03. System Scope and Context
This system includes:
- GitHub repo for code and config
- Azure Databricks for ML compute
- ADLS Gen2 for data storage
- GitHub Actions for CI/CD
- MLflow for tracking
- Unity Catalog (optional) for governance
```

## 04_solution-strategy.md
```markdown
# 04. Solution Strategy
- IaC with Terraform
- Databricks Asset Bundles for deployment
- ML modularized in Python, orchestrated via notebooks
- CI/CD pipelines for validation and deployment
```

## 05_building-blocks.md
```markdown
# 05. Building Blocks View
Key components:
- infra/: Terraform scripts
- src/: Python logic
- notebooks/: Databricks workflows
- pipelines/: GitHub Actions
- tests/: pytest unit tests
- : arc42 docs and diagrams
```

## 06_runtime-view.md
```markdown
# 06. Runtime View
Example: ML training job
1. Load data from ADLS
2. Run notebook on Databricks cluster
3. Log model to MLflow
4. (Optional) Deploy model or evaluate
```

## 07_deployment-view.md
```markdown
# 07. Deployment View
- Azure RG
- Databricks Workspace
- ADLS Gen2
- GitHub Actions runners
- Optional: Unity Catalog and Key Vault
```

## 08_crosscutting.md
```markdown
# 08. Cross-cutting Concepts
- Security: secret scopes, role-based access
- Data governance: Unity Catalog
- Data validation: Great Expectations
- Logging: MLflow, job logs
- Code quality: pre-commit, pytest
```

## 09_architecture-decisions.md
```markdown
# 09. Architecture Decisions
- Terraform over Bicep
- GitHub Actions over Azure DevOps
- Databricks Bundles vs Terraform for jobs
- Unity Catalog optional but encouraged
```

## 10_quality-requirements.md
```markdown
# 10. Quality Requirements
- Scalability: cluster-based parallelism
- Reproducibility: MLflow tracking + Git versioning
- Reliability: retry policies, tests
- Security: role separation, least privilege
```

## 11_risks.md
```markdown
# 11. Risks and Technical Debt
- Bundle API subject to change
- Infra misconfiguration
- Data schema evolution
- Overhead for CI pipeline maintenance
```

## 12_glossary.md
```markdown
# 12. Glossary
- **ADLS Gen2**: Azure Data Lake Storage Gen2
- **MLflow**: Experiment and model tracker
- **Terraform**: IaC tool
- **Asset Bundle**: Declarative Databricks project deployable unit
- **Unity Catalog**: Data governance layer in Databricks
```
