Data Factory (dev) Git Root
===========================

This folder is the Git root for Azure Data Factory code (dev environment).

- Store ADF JSON for pipelines, datasets, linked services, triggers, etc.
- The Terraform configuration can link the dev Data Factory to this GitHub
  repository and root folder so changes are visible in ADF Studio.
- For non-dev environments, deploy via Terraform or your release process
  (e.g., publishing artifacts) rather than Git integration.

Structure suggestion
- data-factory/
  - pipeline/
  - dataset/
  - linkedService/
  - trigger/

