# Databricks Python notebook: Quickstart ETL

from pyspark.sql import functions as F

from bluebrick.config import load_config
from bluebrick.io import ensure_uc_names, get_spark, write_delta
from bluebrick.transformations import clean_sales


# 1) Spark session
spark = get_spark("bluebrick-quickstart")


# 2) Load config (BLUEBRICK_ENV or Databricks widget "bluebrick_env")
cfg = load_config()
catalog, schema, table = ensure_uc_names(cfg["catalog"], cfg["schema"], cfg["table"])


# 3) Create tiny demo dataset (acts as RAW)
src = spark.createDataFrame(
    [(1, " A ", "2024-01-01", 100.0), (2, "B", "2024-01-02", None)],
    "id INT, name STRING, tx_date STRING, amount DOUBLE",
)

# 4) Transform
df_clean = clean_sales(src)
df_clean.createOrReplaceTempView("sales_clean")

# 5) Ensure UC namespaces and write as managed Delta table
spark.sql(f"CREATE CATALOG IF NOT EXISTS {catalog}")
spark.sql(f"CREATE SCHEMA IF NOT EXISTS {catalog}.{schema}")

full_name = f"{catalog}.{schema}.{table}"
write_delta(df_clean, full_name)


# 6) Simple verification queries
count_df = spark.table(full_name).groupBy().count()
schema_df = spark.table(full_name).limit(0)

try:
    # Databricks notebook display
    display(count_df)
    display(schema_df)
except Exception:
    print("Row count:", count_df.collect()[0][0])
    print("Schema:")
    print("\n".join([f"- {f.name}: {f.dataType}" for f in schema_df.schema.fields]))

