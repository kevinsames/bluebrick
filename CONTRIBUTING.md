# Contributing Guidelines

Welcome! 👋 Thanks for your interest in contributing to this project.

This repository is a template for enterprise-grade Machine Learning and Data Engineering projects using Azure Databricks. To maintain quality and consistency, we follow best practices in code, documentation, and CI/CD workflows.

---

## 🧰 Prerequisites

- Python 3.8+ and `pip`
- Access to Azure and Databricks
- `terraform`, `databricks-cli`, and `pre-commit` installed
- Fork this repository and create your own working branch

---

## 🛠️ Development Workflow

1. **Clone & Setup**

   ```bash
   git clone https://github.com/your-username/azure-databricks-ml-template.git
   cd azure-databricks-ml-template
   python -m venv .env
   source .env/bin/activate
   pip install -r requirements.txt
   ```

2. **Pre-commit Hooks**

   Install and run `pre-commit`:

   ```bash
   pip install pre-commit
   pre-commit install
   pre-commit run --all-files
   ```

3. **Write Your Code**

   - Place reusable logic in `src/`
   - Add notebooks to `notebooks/`
   - Write unit tests in `tests/`
   - Document any architectural decisions or changes in `docs/arc42-09_design-decisions.md`

4. **Test**

   ```bash
   pytest
   ```

5. **Create a Pull Request**

   - Write a clear title and description
   - Link related issues or enhancements
   - Ensure CI checks pass

---

## 🔍 Code Standards

- Use [Black](https://github.com/psf/black) and [Flake8](https://flake8.pycqa.org/)
- Organize notebooks with markdown headers and explanatory comments
- Modularize code for reuse in production

---

## 🧪 Adding New Tests

Tests live under the `tests/` directory. Each module in `src/` should be covered.

We use:
- `pytest` for unit testing
- Spark fixtures via `conftest.py`

---

## 🧾 License

By contributing, you agree that your contributions will be licensed under the Apache 2.0 license.

---

Thanks again for helping improve this template! 🙏