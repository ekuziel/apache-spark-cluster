# Apache Spark CDC Notebooks

Project-style runnable CDC notebooks matching the structure of `00_joins.ipynb`.

## Structure

Each notebook starts with:

```text
# Title
## 00 — Spark setup and sample data
SparkSession initialization
```

## Important change

These notebooks do not use `write.format("delta").save(...)` or local filesystem Delta paths.

Reason: with `.master("spark://spark-master:7077")`, local filesystem paths such as `/tmp/...` or `/opt/spark/work-dir/...` are not guaranteed to be visible identically from the notebook container and Spark worker containers.

## Contents

| Notebook | Purpose |
|---|---|
| `01_cdc_scd1_delta_merge.ipynb` | Current-state CDC |
| `02_cdc_scd2_delta_history.ipynb` | SCD Type 2 history |
| `03_streaming_cdc_foreachbatch_delta_merge.ipynb` | Streaming-style micro-batch CDC simulation |
| `04_kafka_json_cdc_to_delta_bronze_silver.ipynb` | Kafka JSON CDC parsing pattern |
| `05_delta_change_data_feed.ipynb` | CDC audit and deduplication |
