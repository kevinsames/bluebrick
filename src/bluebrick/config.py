from __future__ import annotations

import os
from pathlib import Path
from typing import Any, Dict

import yaml


def _get_widget_env_default(default_env: str) -> str:
    """If running in Databricks and a widget is defined, use its value as env."""
    try:
        # dbutils exists only on Databricks
        from pyspark.dbutils import DBUtils  # type: ignore
        from pyspark.sql import SparkSession

        spark = SparkSession.getActiveSession() or SparkSession.builder.getOrCreate()
        dbutils = DBUtils(spark)
        return dbutils.widgets.get("bluebrick_env") or default_env
    except Exception:
        return default_env


def _detect_env() -> str:
    env = os.getenv("BLUEBRICK_ENV", "dev").strip() or "dev"
    # Allow Databricks widget to override if present
    env = _get_widget_env_default(env)
    return env


def _find_config_path(env: str) -> Path | None:
    """Search for configs/<env>.yaml from common roots.

    - current working directory
    - project root if running from within src/notebooks
    - package-relative two levels up
    """

    candidate_names = [f"configs/{env}.yaml", f"./configs/{env}.yaml"]

    # 1) CWD-based search
    for name in candidate_names:
        p = Path(name).resolve()
        if p.exists():
            return p

    # 2) If running from within src/notebooks in Databricks, step up
    cwd = Path.cwd().resolve()
    parents = [cwd] + list(cwd.parents)
    for parent in parents:
        p = (parent / "configs" / f"{env}.yaml").resolve()
        if p.exists():
            return p

    return None


def load_config(env: str | None = None) -> Dict[str, Any]:
    """Load BlueBrick configuration for the selected environment.

    Precedence:
    - Databricks widget ``bluebrick_env`` (if defined)
    - ``BLUEBRICK_ENV`` environment variable
    - default: ``dev``

    If the YAML file is not found, returns a sensible default config so the
    quickstart notebook can still run.
    """

    selected_env = (env or _detect_env()).lower()
    cfg_path = _find_config_path(selected_env)

    if cfg_path and cfg_path.exists():
        with cfg_path.open("r", encoding="utf-8") as f:
            return yaml.safe_load(f) or {}

    # Default fallback config
    return {
        "catalog": "main",
        "schema": f"bluebrick_{selected_env}",
        "table": "example_sales",
        "adls_account": "<adls-account-name>",
        "adls_container": "raw",
        "raw_path": "abfss://raw@<adls-account-name>.dfs.core.windows.net/sales/",
        "silver_path": "abfss://silver@<adls-account-name>.dfs.core.windows.net/sales_silver/",
    }

