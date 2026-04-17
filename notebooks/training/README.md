# Certification Prep Notebooks

**Target:** Databricks Certified Associate Developer for Apache Spark (v3.5)


## Notebooks by exam topic

| Notebook | Exam Topic | Weight |
|---|---|---|
| `01_spark_architecture` | Architecture, driver/executor, deployment modes, lazy eval, fault tolerance, GC | ~17% |
| `02_dataframe_api` | select/filter/sort/agg/join/union/missing data/repartition | ~35% |
| `03_spark_sql` | Temp views, window functions, Catalyst optimizer, SQL functions | ~15% |
| `04_udfs` | Python UDF, Pandas UDF, built-in functions vs UDF performance | ~10% |
| `05_structured_streaming` | Output modes, triggers, checkpointing, watermarking | ~13% |
| `06_performance_optimization` | Caching, broadcast joins, AQE, skew, explain() | ~15% |
| `07_pandas_api_on_spark` | pyspark.pandas, to_spark(), toPandas() memory warning | ~5% |

## Key facts to memorize

**Actions vs Transformations**
- Transformations (lazy): filter, select, withColumn, groupBy, join, repartition
- Actions (eager): count, collect, show, first, take, write/save, toPandas

**Output modes**
- `append` — new rows only; aggregations require watermark
- `complete` — full table every trigger; aggregations, unbounded state
- `update` — changed rows only; most efficient

**Join types**
- `inner` — matching rows only
- `left` / `left_outer` — all left + nulls for unmatched right
- `left_semi` — left rows that HAVE a match (no right columns)
- `left_anti` — left rows that have NO match
- `cross` — cartesian product

**count() null behaviour**
- `count("*")` — counts ALL rows including nulls
- `count("col")` — counts NON-NULL values only

**repartition vs coalesce**
- `repartition(N)` — full shuffle, balanced, can increase or decrease
- `coalesce(N)` — no shuffle when decreasing, unbalanced, faster
