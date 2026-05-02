# Medallion Pattern — Basic

This folder contains a deliberately simple Medallion notebook.

Flow:

```text
RAW -> BRONZE -> SILVER -> GOLD
              |
              -> QUARANTINE
```

## Notebook

- `00_basic.ipynb`

The notebook uses the same SparkSession style as the joins notebooks:

```python
spark = SparkSession.getActiveSession()
if spark is not None:
    spark.stop()

spark = (
    SparkSession.builder
    .appName("medallion-basic")
    .master("spark://spark-master:7077")
    .config("spark.sql.shuffle.partitions", "4")
    .config("spark.sql.adaptive.enabled", "true")
    .config("spark.sql.warehouse.dir", "/tmp/spark_medallion_warehouse")
    .getOrCreate()
)
```
