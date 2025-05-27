# 06. Runtime View

This section describes how the system operates at runtime, covering both the execution of ML pipelines on Databricks and the CI/CD automation workflow. Two primary runtime scenarios are illustrated: (a) an ML pipeline job execution and (b) the CI/CD workflow that delivers code to the environment.

## a. ML Pipeline Job Execution (Training & Inference Workflow)

Once deployed, the Databricks environment runs scheduled or on-demand jobs to perform data processing and model training. A typical sequence for a model training pipeline is as follows:

1. **Scheduled Trigger or Manual Start:**  
   A Databricks Job (configured via the asset bundle) is triggered—either on a schedule (e.g., nightly at 1 AM) or manually by a user or API.

2. **Cluster Launch:**  
   Databricks spins up a Spark cluster for the job, using either an existing interactive cluster or a new job cluster as specified (runtime version, node type, autoscaling, etc.).

3. **Notebook Execution (Data Prep):**  
   The first task runs the “Prepare Data” notebook, which reads input data from ADLS Gen2 (e.g., Parquet or Delta files). Secure access is provided via service principal credentials or Unity Catalog. The notebook uses PySpark to clean and transform data, writing processed output (such as a Delta table of features) back to the data lake or DBFS.

4. **Notebook Execution (Model Train):**  
   The “Train Model” notebook loads the prepared data, invokes functions from `/src` to train a model (e.g., using scikit-learn or Spark MLlib), and logs metrics and artifacts to MLflow. MLflow tracks parameters, metrics, and model artifacts for traceability.

5. **Notebook Execution (Evaluation & Register):**  
   The “Evaluate Model” notebook loads the trained model (from MLflow or file system), tests it on a validation set, and compares metrics with previous models. If the new model is better, it is registered in MLflow Model Registry (e.g., tagged as “Staging”). With Unity Catalog, model registry entries are workspace-independent.

6. **Notebook Execution (Batch Inference or Other):**  
   A “Batch Inference” job can load the latest production model from MLflow/Unity Catalog, apply it to new input data, and write predictions back to the lake or a database.

7. **Job Completion:**  
   After all tasks finish, the Databricks job reports success or failure. Logs and results are available in the Databricks Job Run UI, and MLflow UI provides experiment tracking.

8. **Notifications & Monitoring:**  
   Jobs can be configured to send alerts on failure (e.g., email, Slack). Monitoring steps can compare validation metrics over time to detect model drift or performance degradation.

**Data flows:**  
ADLS (data lake) → Databricks cluster (processing) → ADLS (processed data/models); metrics & models flow into MLflow for tracking. Unity Catalog (if used) governs data access and audit logging.

**Job orchestration:**  
Databricks Jobs can define multi-task jobs with dependencies (e.g., Data Prep → Train → Evaluate). The asset bundle YAML or Terraform can define these workflows.

---

## b. CI/CD Pipeline Execution (Automation Workflow)

The CI/CD pipelines automate validation and deployment:

1. **Developer Commit & CI Trigger:**  
   A developer pushes changes (e.g., to `/notebooks` or `/src`). GitHub triggers the CI workflow (`ci-build-test`).

2. **CI (Build & Test) Steps:**  
   - **Linting:** Runs black and flake8 for code style.
   - **Testing:** Runs pytest (including PySpark tests). Optionally, executes notebooks via Papermill or similar.
   - **Notebook Validation:** Ensures notebooks execute without error.

3. **CI Outcomes:**  
   If all checks pass, the commit/PR is marked green. Failures notify the developer for fixes.

4. **Merge and CD Deploy Trigger:**  
   On merge to main, CD workflows run:
   - **cd-deploy-infra.yml:** Applies Terraform to provision/update Azure resources (Databricks workspace, ADLS, service principals, Unity Catalog, etc.).
   - **cd-deploy-databricks.yml:** Installs Databricks CLI, authenticates, and runs `databricks bundle deploy` to synchronize notebooks, jobs, and configs with the workspace.

5. **Post-Deployment Verification:**  
   Optionally, triggers a test job in Databricks to verify deployment (e.g., using `databricks jobs run-now`).

6. **Notifications:**  
   GitHub Actions marks workflows as success/failure and can notify the team (e.g., via Slack or email).

7. **Promotion to Production:**  
   Promotion to production may be a separate step (e.g., via a release branch or tag), running the same deployment steps against production resources.

**Traceability:**  
Each build and deploy is logged in GitHub, enabling traceability from git commit to deployed environment. Asset Bundles enable a GitOps workflow, ensuring the running environment matches the codebase and reducing manual configuration drift.

---

This runtime view demonstrates how the template automates the end-to-end ML workflow, from code commit to production deployment, leveraging Databricks, Azure, and CI/CD best practices.