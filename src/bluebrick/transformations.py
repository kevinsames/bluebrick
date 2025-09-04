from __future__ import annotations

from pyspark.sql import DataFrame
from pyspark.sql import functions as F


def clean_sales(df: DataFrame) -> DataFrame:
    """Clean and normalize a simple sales dataset.

    Transformations (deterministic):
    - Trim and uppercase `name`
    - Cast `tx_date` to DATE
    - Cast `amount` to DOUBLE
    - Filter out rows with null/NaN amount or non-positive id

    Parameters
    ----------
    df: DataFrame
        Source DataFrame with columns: id, name, tx_date, amount

    Returns
    -------
    DataFrame
        Cleaned DataFrame with normalized types and values
    """

    cleaned = (
        df.withColumn("name", F.upper(F.trim(F.col("name"))))
        .withColumn("tx_date", F.to_date(F.col("tx_date")))
        .withColumn("amount", F.col("amount").cast("double"))
        .filter(F.col("id") > F.lit(0))
        .filter(F.col("amount").isNotNull())
    )

    return cleaned
