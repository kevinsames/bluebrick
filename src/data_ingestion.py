from pyspark.sql import DataFrame, SparkSession
from pyspark.sql.functions import col


def read_csv(spark: SparkSession, path: str, header: bool = True, infer_schema: bool = True) -> DataFrame:
    """
    Reads a CSV file from the given path into a Spark DataFrame.
    """
    return spark.read.option("header", str(header)).option("inferSchema", str(infer_schema)).csv(path)


def select_columns(df: DataFrame, columns: list) -> DataFrame:
    """
    Select specified columns from the DataFrame.
    """
    return df.select([col(c) for c in columns])


def filter_nulls(df: DataFrame, column: str) -> DataFrame:
    """
    Filter out rows where the specified column is null.
    """
    return df.filter(col(column).isNotNull())