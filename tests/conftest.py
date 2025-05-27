# How to use:
#	•	Save it as tests/conftest.py
#	•	In your tests, just include spark as a function argument:

#def test_read_csv(spark):
#    from project.data_ingestion import read_csv
#    df = read_csv(spark, "tests/resources/sample.csv")
#    assert df.count() > 0

import pytest
from pyspark.sql import SparkSession


@pytest.fixture(scope="session")
def spark():
    """
    Provides a SparkSession for testing.
    Runs in local mode with 2 threads.
    """
    spark = (
        SparkSession.builder
        .master("local[2]")
        .appName("pytest-spark")
        .config("spark.ui.enabled", "false")
        .getOrCreate()
    )
    yield spark
    spark.stop()

