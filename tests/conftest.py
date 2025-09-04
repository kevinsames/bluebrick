import os
import shutil
import sys
import tempfile
from pathlib import Path
from typing import Iterator

import pytest
from pyspark.sql import SparkSession


@pytest.fixture(scope="session")
def spark_session() -> Iterator[SparkSession]:
    """Create a lightweight local Spark session for tests."""

    # Ensure an isolated warehouse for Delta metadata even if unused
    tmpdir = tempfile.mkdtemp(prefix="bluebrick_spark_")
    # Ensure src/ is importable for tests without install
    repo_root = Path(__file__).resolve().parents[1]
    src_dir = str(repo_root / "src")
    if src_dir not in sys.path:
        sys.path.insert(0, src_dir)
    # Make local networking deterministic for Spark in CI/dev
    os.environ.setdefault("SPARK_LOCAL_IP", "127.0.0.1")
    os.environ.setdefault("PYSPARK_PYTHON", sys.executable)

    spark = (
        SparkSession.builder.master("local[1]")
        .appName("bluebrick-tests")
        .config("spark.ui.showConsoleProgress", "false")
        .config("spark.sql.shuffle.partitions", "1")
        .config("spark.sql.warehouse.dir", os.path.join(tmpdir, "warehouse"))
        .config("spark.driver.bindAddress", "127.0.0.1")
        .config("spark.driver.host", "127.0.0.1")
        .config("spark.driver.extraJavaOptions", "-Djava.net.preferIPv4Stack=true")
        .getOrCreate()
    )
    try:
        yield spark
    finally:
        spark.stop()
        shutil.rmtree(tmpdir, ignore_errors=True)
