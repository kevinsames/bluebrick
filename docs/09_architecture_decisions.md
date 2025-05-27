# 09. Architecture Decisions

During the design of this template, several key architecture decisions (AD) were made:

- **AD1: Use Azure Databricks (Spark) as the ML compute platform**  
  Instead of alternatives like Azure ML or self-managed Spark, Databricks was chosen for its unified environment (combining data engineering and ML) and managed Spark capabilities. This ensures scalability for large data and tight integration with MLflow. Databricks notebooks are preferred by many data scientists. The trade-off is vendor lock-in, but the productivity and performance benefits in an enterprise setting were deemed worth it.

- **AD2: Separate notebooks for orchestration and Python modules for logic**  
  To balance interactive development with code quality, the project is partitioned into notebooks (for high-level pipeline steps and exploration) and a Python package (for core logic). This addresses the problem of having all code in notebooks (harder to test/reuse) or all code in scripts (less accessible to data scientists). Supporting both ensures good practices without alienating notebook-centric users.

- **AD3: Use Terraform for all infrastructure provisioning**  
  Terraform was chosen over Azure CLI scripts or ARM templates because it is cloud-agnostic, modular, and declarative with strong state management. This fits the enterprise desire to treat infrastructure as code, reviewed in PRs, and integrates well with GitHub Actions. The learning curve is justified by the need for reproducibility.

- **AD4: Use Databricks Asset Bundles for deploying workspace artifacts**  
  Instead of manual CLI imports or using the Workspace API directly, Asset Bundles (a newer IaC-like approach) are adopted. This encapsulates Databricks workspace configuration in code, aligning with GitOps. While Asset Bundles are relatively new, they provide a unified workflow for deploying code and job definitions. The alternative (Terraform Databricks provider for jobs/notebooks) is less straightforward for notebooks. The preview status of bundles was accepted for the structural and strategic benefits.

- **AD5: Integrate MLflow for model tracking**  
  MLflow (already present in Databricks) is used as the single source of truth for experiments and model versions. This simplifies model promotion and is critical for MLOps workflows.

- **AD6: Optional Unity Catalog usage for governance**  
  Unity Catalog integration is optional. The template is designed so adding UC is straightforward, but not required by default. UC was chosen for its ability to define permissions across workspaces and track data lineage. The alternative (legacy Hive metastore and manual ACLs) is less scalable for enterprise needs.

- **AD7: Employ GitHub Actions over other CI/CD**  
  As the template is hosted on GitHub, GitHub Actions was chosen for CI/CD pipelines for convenience and seamless integration. Alternatives like Azure DevOps were considered, but GitHub Actions lowers friction for open-source and is now a first-class CI/CD tool.

- **AD8: Include NYC Taxi dataset example**  
  For user-friendliness, a known example dataset (NYC Taxi trips) and example pipelines are included. This helps users understand the template. The example is lightweight to avoid overwhelming resources.

- **AD9: Structure documentation using arc42**  
  The arc42 architecture framework is used for documentation (sections 1-12). This comprehensively covers all aspects of the solution and provides clarity for maintainers and stakeholders.

- **AD10: Testing strategy with pytest and sample data**  
  All Python modules must have unit tests (with sample or synthetic data), and critical pipeline paths should have integration tests. Logic is moved out of notebooks into testable functions. Notebooks receive minimal smoke tests to ensure they run top-to-bottom.

- **AD11: Pre-commit and style enforcement**  
  Pre-commit hooks (Black, Flake8) are included to ensure code consistency. This saves time and catches simple errors early.

- **AD12: Use of Databricks Jobs API vs. external orchestrator**  
  Databricks Jobs are used for orchestration of ML tasks rather than introducing an external orchestrator (like Azure Data Factory or Airflow). This keeps everything within Databricks and under IaC. If pipelines become very complex, external orchestration can be introduced later.

Each of these decisions is documented so that if conditions change, maintainers understand the original reasoning and can adapt accordingly. Architecture Decision Records (ADRs) can be added to `/docs` to track any changes in these decisions over time.