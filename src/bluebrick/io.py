from __future__ import annotations

import logging
import os
import re

from pyspark.sql import DataFrame, SparkSession


def get_spark(app_name: str = "bluebrick") -> SparkSession:
    """Return an active SparkSession, creating a local one if needed.

    On Databricks, the global ``spark`` variable is already available.
    When running locally (e.g., tests), create a lightweight local session.
    """

    # Reuse an existing session if present
    try:
        spark = SparkSession.getActiveSession()
        if spark is not None:
            return spark
    except Exception as exc:  # pragma: no cover - environment dependent
        logging.getLogger(__name__).debug("No active SparkSession detected; creating a new one: %s", exc)

    # Harden local startup for notebooks/CI where hostname may not resolve
    os.environ.setdefault("SPARK_LOCAL_IP", "127.0.0.1")

    return (
        SparkSession.builder.master("local[1]")
        .appName(app_name)
        .config("spark.sql.shuffle.partitions", "1")
        .config("spark.ui.showConsoleProgress", "false")
        .config("spark.driver.bindAddress", "127.0.0.1")
        .config("spark.driver.host", "127.0.0.1")
        .config("spark.driver.extraJavaOptions", "-Djava.net.preferIPv4Stack=true")
        .getOrCreate()
    )


def ensure_uc_names(catalog: str, schema: str, table: str) -> tuple[str, str, str]:
    """Normalize UC catalog/schema/table names: lowercase and ``[a-z0-9_]+``.

    Raises ``ValueError`` if any component is empty after normalization.
    """

    def _norm(s: str) -> str:
        s = (s or "").strip().lower()
        s = re.sub(r"[^a-z0-9_]", "_", s)
        s = re.sub(r"_+", "_", s).strip("_")
        return s

    c, s, t = _norm(catalog), _norm(schema), _norm(table)
    if not c or not s or not t:
        raise ValueError("catalog, schema, and table must be non-empty after normalization")
    return c, s, t


def read_csv(
    spark: SparkSession,
    path: str,
    *,
    header: bool = True,
    schema: str | None = None,
    infer_schema: bool = True,
) -> DataFrame:
    """Read a CSV file or directory with sensible defaults.

    Works with local paths (file:/), DBFS (dbfs:/), and ABFSS URIs.
    """

    reader = spark.read.option("header", str(header).lower())
    if schema:
        reader = reader.schema(schema)
    else:
        reader = reader.option("inferSchema", str(infer_schema).lower())
    return reader.csv(path)


def write_delta(df: DataFrame, destination: str, *, mode: str = "overwrite") -> None:
    """Write a DataFrame as Delta to a UC table name or a path.

    If ``destination`` looks like ``catalog.schema.table``, writes a managed table
    via ``saveAsTable``. Otherwise, writes to a filesystem/ABFSS/DBFS path.
    """

    parts = destination.split(".")
    if len(parts) == 3:
        df.write.format("delta").mode(mode).saveAsTable(destination)
    else:
        df.write.format("delta").mode(mode).save(destination)
