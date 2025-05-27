import os
import logging
from pyspark.sql import SparkSession


def get_spark_session(app_name: str = "ml-template") -> SparkSession:
    """
    Returns a SparkSession with common config.
    """
    spark = SparkSession.builder.appName(app_name).getOrCreate()
    return spark


def get_logger(name: str = __name__) -> logging.Logger:
    """
    Returns a configured logger.
    """
    logger = logging.getLogger(name)
    handler = logging.StreamHandler()
    formatter = logging.Formatter("%(asctime)s %(levelname)s %(name)s: %(message)s")
    handler.setFormatter(formatter)
    if not logger.hasHandlers():
        logger.addHandler(handler)
    logger.setLevel(logging.INFO)
    return logger


def get_env_variable(key: str, default: str = None) -> str:
    """
    Safely get environment variable with optional default.
    """
    value = os.getenv(key)
    if value is None:
        if default is not None:
            return default
        raise EnvironmentError(f"Missing required environment variable: {key}")
    return value