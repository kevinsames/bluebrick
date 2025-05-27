from pyspark.sql import DataFrame
from pyspark.sql.functions import col, when, isnan


def add_ratio_column(df: DataFrame, numerator: str, denominator: str, new_column: str) -> DataFrame:
    """
    Add a new column that represents the ratio of two existing columns.
    """
    return df.withColumn(
        new_column,
        when(col(denominator) != 0, col(numerator) / col(denominator)).otherwise(None)
    )


def fill_missing_values(df: DataFrame, fill_value: dict) -> DataFrame:
    """
    Fill missing values in specified columns with provided defaults.

    Args:
        df: Input DataFrame
        fill_value: Dictionary of {column: value}

    Returns:
        DataFrame with filled values
    """
    return df.fillna(fill_value)


def drop_null_rows(df: DataFrame, subset: list) -> DataFrame:
    """
    Drop rows that have null or NaN values in the specified subset of columns.

    Args:
        df: Input DataFrame
        subset: List of column names to check for nulls

    Returns:
        Filtered DataFrame
    """
    return df.dropna(subset=subset)