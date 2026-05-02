# Apache Spark 4.0.2 — Local Cluster with Gluten/Velox, Kafka, Iceberg, Delta, Avro, Hudi, JupyterLab

A local development environment for testing and benchmarking Spark features and performance.

| Mode | Command | Description |
|---|---|---|
| **Vanilla** | `make up` | Standard JVM-based Spark execution |
| **Gluten/Velox** | `make up-gluten` | Native columnar execution via Gluten 1.6.0 + Velox |
| **Kafka** | `make up-kafka` |  with Kafka broker + Kafka UI |


## Stack

| Component | Version | Notes |
|---|---|---|
| Apache Spark | **4.0.2** | Scala 2.13, Java 17 — https://archive.apache.org/dist/spark/spark-4.0.2/ |
| Apache Gluten | **1.6.0** | Velox backend — supports Spark 4.0.x — https://repo1.maven.org/maven2/org/apache/gluten/ |
| Apache Iceberg | **1.10.1** | `iceberg-spark-runtime-4.0_2.13` — https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-4.0_2.13/1.10.1/ |
| Delta Lake | **4.0.1** | `delta-spark_2.13` — https://repo1.maven.org/maven2/io/delta/delta-spark_2.13/4.0.1/ |
| Apache Avro | **4.0.2** | `spark-avro_2.13` — https://repo1.maven.org/maven2/org/apache/spark/spark-avro_2.13/4.0.2/ |
| Apache Hudi | **1.1.1** | `hudi-spark4.0-bundle_2.13` — https://repo1.maven.org/maven2/org/apache/hudi/hudi-spark4.0-bundle_2.13/1.1.1/ |
| Apache Kafka | **3.9.1** | KRaft mode, Scala 2.13 — https://archive.apache.org/dist/kafka/3.9.1/ |
| Kafka UI | **1.2.0** | `ghcr.io/kafbat/kafka-ui:v1.2.0` — https://github.com/kafbat/kafka-ui |
| Spark Kafka Connector | **4.0.2** | `spark-sql-kafka-0-10_2.13` — https://repo1.maven.org/maven2/org/apache/spark/spark-sql-kafka-0-10_2.13/4.0.2/ |
| JupyterLab | **4.x** | https://jupyter.org/ |
| Base OS | Ubuntu 22.04 | https://releases.ubuntu.com/22.04/ |

> **Note:** Gluten 1.6.0 was tested against Spark 4.0.1. Running on 4.0.2 produces a harmless
> `version not matched` warning — everything works correctly.


## Deployed JARs

All JARs are downloaded at Docker build time into `${SPARK_HOME}/jars/`.

| JAR | Version | Purpose | Active by default |
|---|---|---|---|
| `iceberg-spark-runtime-4.0_2.13` | 1.10.1 | Iceberg catalog + table format | ✅ Yes — configured in `spark-defaults.conf` |
| `delta-spark_2.13` | 4.0.1 | Delta Lake table format + DML | ✅ Yes — configured in `spark-defaults.conf` |
| `delta-storage` | 4.0.1 | Delta Lake storage abstraction layer | ✅ Yes — required by delta-spark |
| `spark-avro_2.13` | 4.0.2 | Avro read/write (`format("avro")`) | ✅ Yes — auto-loaded from jars/ |
| `gluten-velox-bundle-spark4.0_2.13` | 1.6.0 | Gluten native execution engine | ⚙️ Only in `make up-gluten` mode |
| `hudi-spark4.0-bundle_2.13` | 1.1.1 | Hudi data lake framework  | ✅ Yes — auto-loaded from jars/ |
| `spark-sql-kafka-0-10_2.13` | 4.0.2 | Spark Structured Streaming Kafka source/sink | ✅ Yes — auto-loaded from jars/ |
| `spark-token-provider-kafka-0-10_2.13` | 4.0.2 | Kafka delegation token provider for Spark | ✅ Yes — required by Spark Kafka connector |
| `kafka-clients` | 3.9.1 | Kafka client driver used by Spark connector | ✅ Yes — required by Spark Kafka connector |
| `spark-measure_2.13` | 0.27 | Spark stage/task metrics (debugging & benchmarking) | ✅ Yes — auto-loaded from jars/ |

### Spark extensions activated in `spark-defaults.conf`

```
spark.sql.extensions = org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions,
                       io.delta.sql.DeltaSparkSessionExtension

spark.sql.catalog.spark_catalog = org.apache.spark.sql.delta.catalog.DeltaCatalog
spark.sql.catalog.local          = org.apache.iceberg.spark.SparkCatalog
spark.sql.catalog.local.type     = hadoop
spark.sql.catalog.local.warehouse = /workspace/data/warehouse/iceberg
```

Avro and standard Parquet/ORC/JSON/CSV are available without any extra configuration —
they are part of Spark core or auto-loaded from the jars directory.


## Architecture

```
┌──────────────────────────────────────────────────────────┐
│  Docker network: spark-net                               │
│                                                          │
│  spark-master   :8080 (UI)  :7077 (cluster)              │
│       ├── spark-worker-1   :8081                         │
│       └── spark-worker-2   :8082                         │
│                                                          │
│  spark-history  :18080                                   │
│  spark-connect  :15002 (gRPC)                            │
│                                                          │
│  notebook       :8888  (JupyterLab)  :4040 (App UI)      │
│                                                          │ 
│  kafka          :9092  (internal)    :9094 (host)        │
│  kafka-ui       :8090                                    │
└──────────────────────────────────────────────────────────┘
```

## Quick Start

```bash
# 1. Clone
git clone https://github.com/<your-username>/spark-cluster.git
cd spark-cluster

# 2. Init directories + .env
make init

# 3. Build image (~10 min first time — downloads Gluten JAR ~98 MB)
make build

# 4a. Vanilla mode
make up

# 4b. Gluten/Velox mode
make up-gluten

# 5. Generate benchmark data inside the notebook container
make data

# 6. Open JupyterLab
make notebook      # → http://localhost:8888  token: spark
```

## URLs

| Service | URL |
|---|---|
| Spark Master UI | http://localhost:8080 |
| Worker 1 | http://localhost:8081 |
| Worker 2 | http://localhost:8082 |
| History Server | http://localhost:18080 |
| JupyterLab | http://localhost:8888 (token: `spark`) |
| Spark App UI | http://localhost:4040 (active job only) |
| Spark Connect (gRPC) | sc://localhost:15002 |
| Kafka UI | http://localhost:8090 |


## Kafka Notes

- Kafka runs in KRaft mode, without ZooKeeper.
- Internal Docker network bootstrap server: `kafka:9092`
- Host bootstrap server: `localhost:9094`
- Kafka UI is available at `http://localhost:8090`
- Spark uses `spark-sql-kafka-0-10_2.13:4.0.2` with Spark 4.0.2 / Scala 2.13.
- Kafka is optional: `make up` starts Spark without Kafka, while `make up-kafka` starts the full Spark + Kafka stack.



## Project Structure

```
spark-cluster/
├── Dockerfile
├── kafka.Dockerfile
├── docker-compose.yml
├── docker-compose.kafka.yml
├── docker-compose.override.yml
├── entrypoint.sh
├── Makefile
├── conf/
│   └── spark-defaults.conf
├── scripts/
│   ├── generate_data.py
│   └── test_connection.py
├── notebooks/
│   ├── 01_dataframe_basics.ipynb
│   ├── 02_caching_partitioning.ipynb
│   ├── 03_parquet_iceberg_delta.ipynb
│   ├── 04_streaming_udf_aqe.ipynb
│   ├── 05_generate_benchmark_data.ipynb
│   ├── 06_benchmark_vanilla_vs_gluten.ipynb
│   ├── 07_benchmark_delta_vs_iceberg_vs_hudi.ipynb
│   ├── 08_benchmark_delta_vs_iceberg_vs_hudi_advanced.ipynb
│   ├── 09_real_world_pipeline_delta_vs_hudi.ipynb
│   ├── 10_pyspark_performance_optimization.ipynb
│   │
│   ├── features/
│   │   └── 01-powerful-spark-4.x-features.ipynb
│   │
│   ├── gluten_velox/                        ← Gluten/Velox deep dives
│   │   ├── README.md
│   │   ├── 01_fallback_analysis.ipynb
│   │   ├── 02_velox_performance_deep_dive.ipynb
│   │   └── 03_off_heap_memory.ipynb
│   │
│   ├── joins/                               ← Join patterns & strategies
│   │   ├── 00_joins.ipynb
│   │   ├── 01_join_strategies_deep_dive.ipynb
│   │   ├── 02_broadcast_vs_shuffle.ipynb
│   │   ├── 03_aqe_join_optimization.ipynb
│   │   ├── 04_skew_handling.ipynb
│   │   └── 05_large_scale_join_benchmark.ipynb
│   │
│   ├── extensions/                          ← JupyterLab + Spark extensions
│   │   ├── README.md
│   │   ├── 00_extensions.ipynb
│   │   ├── 01_spark_extensions.ipynb
│   │   ├── 02_spark_debugging.ipynb
│   │   ├── 03_sparkmeasure.ipynb
│   │   └── 04_sparkmeasure_explained.ipynb
│   │
│   ├── performance_internals/               ← Query planning & optimization
│   │   ├── README.md
│   │   ├── 01_query_plan_deep_dive.ipynb
│   │   ├── 02_aqe_deep_dive.ipynb
│   │   ├── 03_memory_management.ipynb
│   │   └── 04_join_strategies.ipynb
│   │
│   ├── data_formats_storage/                ← File formats & storage
│   │   ├── README.md
│   │   ├── 01_format_benchmark.ipynb
│   │   ├── 02_iceberg_advanced.ipynb
│   │   ├── 03_delta_advanced.ipynb
│   │   ├── 04_iceberg_advanced_2.ipynb
│   │   ├── 05_delta_advanced_2.ipynb
│   │   ├── 06_parquet_internals.ipynb
│   │   ├── 07_avro_schema_registry.ipynb
│   │   └── basics/
│   │       ├── README.md
│   │       ├── csv/
│   │       ├── delta/
│   │       ├── parquet/
│   │       ├── hudi/
│   │       ├── iceberg/
│   │       ├── avro/
│   │       ├── orc/
│   │       ├── json/
│   │       └── protobuf/
│   │
│   ├── streaming/                           ← Structured Streaming
│   │   ├── README.md
│   │   ├── 01_structured_streaming_fundamentals.ipynb
│   │   ├── 02_streaming_iceberg.ipynb
│   │   └── 03_stateful_operations.ipynb
│   │
│   ├── configuration/                       ← Spark configuration
│   │   ├── README.md
│   │   ├── 01_active_configuration.ipynb
│   │   └── 02_all_parameters.ipynb
│   │
│   └── training/                            ← Spark Developer cert prep (7 notebooks)
│       ├── README.md
│       ├── 01_spark_architecture.ipynb
│       ├── 02_dataframe_api.ipynb
│       ├── 03_spark_sql.ipynb
│       ├── 04_udfs.ipynb
│       ├── 05_structured_streaming.ipynb
│       ├── 06_performance_optimization.ipynb
│       └── 07_pandas_api_on_spark.ipynb
│
├── docs/
│   └── windows-tips.md
├── data/                                    ← Parquet data (git-ignored)
└── spark-events/                            ← History Server logs (git-ignored)
```

## Notebooks

### Core notebooks

| # | Notebook | Topic | Level |
|---|---|---|---|
| 01 | DataFrame Basics | DataFrame API, SQL, window functions, CTEs | Beginner |
| 02 | Caching & Partitioning | persist, broadcast join, partitioning strategies | Beginner |
| 03 | Parquet / Iceberg / Delta | formats, ACID, time travel, MERGE | Intermediate |
| 04 | Streaming, UDF, AQE | structured streaming, pandas UDF, explain() | Intermediate |
| 05 | Generate Benchmark Data | TPC-H style data generation in Spark | Intermediate |
| 06 | Benchmark Vanilla vs Gluten | TPC-H queries, timing, comparison chart | Advanced |
| 07 | Benchmark Delta vs Iceberg vs Hudi | Basic write/read benchmark across lakehouse formats | Intermediate |
| 08 | Benchmark Advanced (Delta vs Iceberg vs Hudi) | MERGE/UPSERT, file layout, small files, EXPLAIN plans, charts | Advanced |
| 09 | Real-world Pipeline (Delta vs Hudi) | Bronze/Silver pipeline, MERGE vs UPSERT, CDC vs incremental queries | Production |
| 10 | PySpark Performance Optimization | partitioning, caching, broadcast joins, filter pushdown, shuffle tuning | Production |



### `features/` — Spark 4.x feature showcase

| Notebook | What you will learn | Level |
|---|---|---|
| `01-powerful-spark-4.x-features` | End-to-end overview of modern Spark 4.x capabilities: AQE + DPP, Pandas API on Spark, Delta Lake (time travel, Z-Order), Structured Streaming (`foreachBatch`, `availableNow`), Iceberg (schema evolution, hidden partitioning), RAPIDS (GPU detection), Spark Connect (remote execution), and MLlib pipelines with optional ONNX export | Intermediate |


### `gluten_velox/` — Gluten/Velox deep dives

| Notebook | What you will learn | Level |
|---|---|---|
| `01_fallback_analysis` | Which operators offload to Velox vs fall back to JVM, how to measure offload rate, why Python UDFs always fall back, decision tree for writing Gluten-friendly queries | Advanced |
| `02_velox_performance_deep_dive` | Why Velox is faster (SIMD, columnar, native Parquet), 18-query benchmark across scan/filter/agg/join/sort/string, vanilla vs Gluten speedup report with median/p25/p75 | Advanced |
| `03_off_heap_memory` | Three memory pools (on-heap/off-heap/overhead/Velox native), GC pressure profiling, Tungsten off-heap config, Velox memory tuning, OOM diagnosis guide | Production |


### `joins/` — Join patterns & strategies

| Notebook | What you will learn | Level |
|---|---|---|
| `00_joins` | All join types, semi/anti joins, cross/self joins, multi-key joins, null handling, duplicate keys, broadcast joins, execution plans, skew handling, optional bucketed joins | Intermediate → Advanced |
| `01_join_strategies_deep_dive` | Physical join strategies, BroadcastHashJoin, SortMergeJoin, ShuffledHashJoin, join hints, physical plan comparison | Advanced |
| `02_broadcast_vs_shuffle` | Broadcast joins vs shuffle joins, auto broadcast threshold, forced broadcast, disabled broadcast, runtime and memory trade-offs | Advanced |
| `03_aqe_join_optimization` | AQE on/off comparison, runtime plan changes, dynamic broadcast, shuffle partition coalescing, AQE skew join handling | Advanced |
| `04_skew_handling` | Hot key simulation, partition metrics, skew diagnosis, AQE skew handling, manual salting, salted join comparison | Advanced |
| `05_large_scale_join_benchmark` | Larger synthetic benchmarks across shuffle, broadcast, AQE, filtered dimensions, skewed joins, salting, and decision tables | Production |


### `extensions/` — JupyterLab and Spark extensions

| Notebook | What you will learn | Level |
|---|---|---|
| `00_extensions` | JupyterLab 4.x productivity tools: widgets, progress bars, interactive tables/charts, SQL helpers, notebook diffs, output stripping, formatting and linting | Intermediate |
| `01_spark_extensions` | Spark-specific helper libraries and native PySpark diagnostics for validation, data quality checks, profiling and DataFrame testing | Intermediate |
| `02_spark_debugging` | Practical Spark debugging patterns for plans, joins, AQE, skew, caching, partitioning and runtime comparison | Advanced |
| `03_sparkmeasure` | sparkMeasure examples for stage/task metrics, shuffle, joins, caching, AQE and skew analysis | Advanced |
| `04_sparkmeasure_explained` | How to interpret aggregated sparkMeasure metrics such as executor time, CPU time, GC, spill and shuffle read/write | Advanced |


### `performance_internals/` — Query planning & optimization

| Notebook | What you will learn | Level |
|---|---|---|
| `01_query_plan_deep_dive` | All `explain()` modes, reading physical plans, predicate pushdown into Parquet, join strategy selection, Spark UI guide | Advanced |
| `02_aqe_deep_dive` | All 3 AQE features: partition coalescing, dynamic join conversion, skew join splitting — each with hands-on benchmarks | Advanced |
| `03_memory_management` | Full executor memory model, storage vs execution memory, shuffle spill, off-heap, broadcast variables, GC tuning | Production |
| `04_join_strategies` | All 5 join strategies benchmarked, BroadcastHashJoin vs SortMergeJoin vs ShuffledHashJoin, join hints, skew handling (AQE + manual salting) | Advanced |


### `data_formats_storage/` — File formats & storage

| Notebook | What you will learn | Level |
|---|---|---|
| `01_format_benchmark` | Row vs columnar formats, Parquet/ORC/Avro/CSV write+read benchmark, column pruning, predicate pushdown, compression codec comparison | Intermediate |
| `02_iceberg_advanced` | ACID transactions, MERGE INTO, time travel, schema evolution, partition evolution, row-level DELETE/UPDATE, snapshot management, branching & tagging | Advanced |
| `03_delta_advanced` | Transaction log internals, OPTIMIZE, ZORDER, VACUUM, Change Data Feed, time travel, RESTORE, schema enforcement/evolution, generated columns, data skipping | Advanced |
| `04_iceberg_advanced_2` | CDF for CDC pipelines, branching workflow (dev/staging/prod), MoR vs CoW compaction, metadata tables, row-level delete strategies | Production |
| `05_delta_advanced_2` | Liquid Clustering vs ZORDER, Deletion Vectors, low-shuffle MERGE, dynamic partition overwrite, shallow/deep clone | Production |
| `06_parquet_internals` | Row groups, column chunks, encoding schemes (dict/RLE/delta), column statistics, data skipping, row group size tuning | Advanced |
| `07_avro_schema_registry` | Avro format, schema evolution (backward/forward/full compatibility), Schema Registry pattern, Kafka→Avro→Parquet pipeline, Avro vs Parquet benchmark | Production |


### `basics/csv/` — CSV for ETL and data exchange

| Notebook | What you will learn |
|---|---|
| `01_reading_csv` | spark.read.csv, header, encoding, glob patterns (use Python glob — not Spark glob strings on local FS) |
| `02_writing_csv` | Write modes, compression, date formatting, single file output |
| `03_schema_inference` | inferSchema cost, samplingRatio, explicit schema, type conflicts |
| `04_dirty_data` | PERMISSIVE + columnNameOfCorruptRecord, .cache() required before filtering on _corrupt_record (Spark 4.x) |
| `05_large_csv` | CSV → Parquet pipeline using glob-resolved file list, incremental processing |
| `06_encodings` | UTF-8, Latin-1, BOM handling (Python strip — UTF-8-BOM not supported in Spark 4.x), encoding detection |
| `07_csv_vs_tsv` | RFC 4180, TSV, custom delimiters, quote/escape (single char only) |
| `08_csv_transformations` | Column name normalization, trim/case, type casting |
| `09_csv_to_parquet` | Landing zone → Parquet pipeline, partitioning, validation |
| `10_streaming_csv` | File-based CSV streaming, _corrupt_record in schema required for PERMISSIVE mode |


### `basics/parquet/` — Parquet for analytics storage

| Notebook | What you will learn |
|---|---|
| `01_reading_parquet` | spark.read.parquet(*paths) — list must be unpacked with *, column pruning, metadata |
| `02_writing_parquet` | Compression codecs (snappy/zstd/gzip), write modes, coalesce |
| `03_partitioning` | Partition directory structure, cardinality impact, os.listdir with .is_dir() filter |
| `04_predicate_pushdown` | Statistics-based skipping, supported predicates, explain() verification |
| `05_column_pruning` | Reading only needed columns, nested struct pruning, benchmark |
| `06_schema_evolution` | Adding/removing columns, mergeSchema, type narrowing rejected in Spark 4.x |
| `07_small_files` | Small file problem, compaction with repartition/coalesce |
| `08_compression_codecs` | snappy vs zstd vs gzip vs lz4 — size/speed tradeoffs |
| `09_nested_data` | StructType/ArrayType/MapType, explode, groupBy on nested fields via F.col() |
| `10_performance_tuning` | Diagnosis checklist, cache before loop pattern, before/after benchmark |


### `basics/delta/` — Delta Lake for ACID data lakes

| Notebook | What you will learn |
|---|---|
| `01_first_table` | Create Delta table, writeTo API, table properties, DeltaTable object |
| `02_reading_writing` | Write modes, idempotent writes (txnAppId/txnVersion), parenthesised method chains |
| `03_acid_transactions` | Concurrent writes, optimistic concurrency, conflict resolution |
| `04_updates_deletes` | UPDATE/DELETE/MERGE, explicit INSERT columns (INSERT * requires identical schemas) |
| `05_time_travel` | versionAsOf, timestampAsOf, RESTORE, history, retention |
| `06_optimize_zorder` | OPTIMIZE compaction, ZORDER, OPTIMIZE WHERE on partition columns only, cache-before-loop pattern |
| `07_schema_enforcement` | Schema enforcement, mergeSchema, enableTypeWidening + correct ALTER TABLE syntax |
| `08_change_data_feed` | CDF enable/read, incremental pipeline, UPDATE with DeltaTable API (no LIMIT/subquery) |
| `09_partitioning` | Hive-style partitioning, Liquid Clustering, getattr() instead of Row.get() |
| `10_maintenance` | VACUUM — retentionDurationCheck must be disabled BEFORE VACUUM RETAIN 0 HOURS |


### `basics/hudi/` — Apache Hudi data lake framework

| Notebook | What you will learn |
|---|---|
| `01_hudi_setup_basic_crud` | COW tables, insert/read, Hudi metadata columns, table structure |
| `02_hudi_upserts_duplicate_handling` | Upserts, duplicate handling, precombine logic, latest record selection |
| `03_hudi_deletes_soft_deletes` | Hard vs soft deletes, tombstones, logical delete pattern |
| `04_hudi_merge_on_read_compaction` | MOR tables, delta logs, snapshot vs read-optimized queries, compaction |
| `05_hudi_schema_evolution` | Schema evolution, adding columns, backward compatibility |
| `06_hudi_time_travel_audit` | Time travel, commit instants, audit trail |
| `07_hudi_incremental_queries_cdc` | Incremental queries, CDC pipelines, commit checkpoints |
| `08_hudi_partitioning_data_skipping` | Partitioning strategy, metadata index, data skipping |
| `09_hudi_structured_streaming` | Structured Streaming sink, checkpointing, micro-batches |
| `10_hudi_production_best_practices_monitoring` | Production tuning, monitoring, cleaning, scaling |


### `basics/iceberg/` — Apache Iceberg open table format

| Notebook | What you will learn |
|---|---|
| `01_first_table` | Iceberg catalog (local/hadoop), writeTo API, namespace/table creation |
| `02_reading_writing` | writeTo.createOrReplace() — version-hint.text WARN on first create is expected/harmless |
| `03_snapshots` | Snapshot lifecycle, expire_snapshots, rollback, snapshot isolation |
| `04_time_travel` | snapshot_id/timestamp travel, UPDATE workarounds (no LIMIT, no subquery — collect IDs in Python) |
| `05_partitioning` | Hidden partitioning via F.partitioning.months/bucket/truncate (F.months deprecated in Spark 4.0) |
| `06_schema_evolution` | addColumn/dropColumn/renameColumn, type promotion |
| `07_partition_evolution` | add_partition_field/remove_partition_field without rewrite |
| `08_merge_upsert` | MERGE INTO, MoR vs CoW, tableProperty API, writeTo.createOrReplace() instead of CTAS |
| `09_maintenance` | rewrite_data_files, expire_snapshots, remove_orphan_files, cache-before-loop pattern |
| `10_metadata_tables` | snapshots/files/manifests/history metadata tables, UPDATE workarounds |


### `basics/avro/` — Avro for Kafka streaming pipelines

| Notebook | What you will learn |
|---|---|
| `01_reading_avro` | format("avro").load(list), fastavro for schema inspection (pyarrow.dataset does not support Avro) |
| `02_writing_avro` | avroSchema option, compression, snappy/deflate/bzip2, write modes |
| `03_schema_definition` | record/array/map/union types, StructType+Row() required for nested structs (no tuples) |
| `04_schema_evolution` | Backward/forward compatibility, .load([v1, v2]) list syntax |
| `05_nullable_unions` | ["null","string"] unions, multi-non-null union limitation, JSON string workaround |
| `06_nested_records` | Deeply nested records, array of structs — Row() objects required |
| `07_kafka_simulation` | Kafka producer/consumer simulation, from_avro/to_avro, binary column |
| `08_avro_vs_parquet` | Size/speed benchmark, schema registry pattern, when to use each |
| `09_avro_to_parquet` | Landing zone pipeline, .load(list) syntax, validation |
| `10_avro_compression` | Codec benchmark (null/snappy/deflate/bzip2), size vs speed tradeoffs |


### `basics/orc/` — ORC for Hive ecosystem workloads

| Notebook | What you will learn |
|---|---|
| `01_reading_orc` | spark.read.orc, column pruning, predicate pushdown, stripe metadata |
| `02_writing_orc` | Compression (zlib/snappy/lz4/zstd), stripe size, bloom filters, sorted write |
| `03_orc_internals` | 3-level layout (file/stripe/row-index), encodings, column statistics |
| `04_predicate_pushdown` | Bloom filter pushdown, min/max statistics, supported predicates |
| `05_orc_vs_parquet` | Head-to-head benchmark, schema evolution, ecosystem support, decision guide |
| `06_hive_compatibility` | Hive-style partitioning, ACID ORC, SerDe properties |
| `07_complex_types` | StructType/ArrayType/MapType in ORC, nested column pruning, explode |
| `08_stripe_tuning` | Stripe size benchmark, row index stride, production config template |
| `09_orc_to_parquet` | Migration pipeline, validation, performance comparison after migration |
| `10_performance_tuning` | Diagnosis, optimization checklist, price column (not revenue), before/after benchmark |


### `basics/json/` — JSON for APIs and logs

| Notebook | What you will learn |
|---|---|
| `01_reading_json` | spark.read.json, multiLine, PERMISSIVE/FAILFAST, .cache() required before _corrupt_record filter |
| `02_writing_json` | Compression (bzip2 not bz2), date formatting, single file, write modes |
| `03_schema_inference` | inferSchema cost, samplingRatio risk, primitivesAsString, explicit schema |
| `04_nested_json` | Struct access, explode/posexplode, from_json/to_json, get_json_object, flatten |
| `05_json_streaming` | File streaming, Kafka JSON deserialization, from_json in Structured Streaming |
| `06_json_performance` | JSON vs Parquet vs Avro benchmark, why JSON is slow, convert-first pattern |
| `07_json_schema_validation` | PERMISSIVE + corrupt capture, .cache().count() to materialize before filter |
| `08_json_rest_apis` | Wrapped/paginated API responses, unwrap with explode, normalization |
| `09_json_to_parquet` | Multi-day landing zone, incremental checkpoint, row count validation |
| `10_json_best_practices` | Schema management, deduplication, production checklist, pitfalls |


### `basics/protobuf/` — Protobuf for gRPC and Kafka

| Notebook | What you will learn |
|---|---|
| `01_what_is_protobuf` | Protobuf vs JSON vs Avro, wire types, gRPC use case, Spark integration |
| `02_proto_schema` | proto3 syntax, scalar types, nested messages — grpcio-tools fallback, Python protobuf API fallback |
| `03_serialization` | Wire format internals, Python library, size comparison |
| `04_spark_protobuf` | from_protobuf/to_protobuf, descriptor files — protoc fallback chain (grpcio-tools → protobuf API) |
| `05_schema_evolution` | Field number rules, reserved, wire-compatible changes, vs Avro evolution |
| `06_protobuf_kafka` | Kafka + Protobuf architecture, Confluent SR format, streaming deserialization |
| `07_protobuf_vs_json_avro` | Size/speed benchmark, ecosystem comparison, decision guide |
| `08_nested_protobuf` | nested→StructType, repeated→ArrayType, map→MapType, flatten |
| `09_protobuf_to_parquet` | Binary landing zone, UDF deserializer, Parquet output, validation |
| `10_protobuf_best_practices` | .proto design, descriptor management, Spark checklist, pipeline recap |

### `streaming/` — Structured Streaming

| Notebook | What you will learn | Level |
|---|---|---|
| `01_structured_streaming_fundamentals` | Stream-as-table model, file/memory sources, output modes, watermarking, sliding windows, checkpointing, metrics monitoring | Intermediate |
| `02_streaming_iceberg` | Exactly-once writes to Iceberg, atomic snapshot commits per micro-batch, time travel on streaming data, aggregated streaming sinks, online compaction | Production |
| `03_stateful_operations` | Session windows, mapGroupsWithState, flatMapGroupsWithState, state timeouts, RocksDB state store | Production |


### `configuration/` — Spark configuration

| Notebook | What you will learn | Level |
|---|---|---|
| `01_active_configuration` | All explicitly configured parameters from spark-defaults.conf — live values, categories, explanation | Intermediate |
| `02_all_parameters` | All Spark parameters including defaults — filtering, comparison, export | Advanced |


### `training/` — Databricks Spark Developer Certification Prep

**Target:** Databricks Certified Associate Developer for Apache Spark

| Notebook | Exam Topic | Weight | Level |
|---|---|---|---|
| `01_spark_architecture` | Driver/executor, deployment modes, lazy evaluation, fault tolerance, GC | ~17% | Beginner |
| `02_dataframe_api` | select/filter/sort/agg/join/union/missing data/repartition | ~35% | Beginner |
| `03_spark_sql` | Temp views, window functions, Catalyst optimizer | ~15% | Intermediate |
| `04_udfs` | Python UDF, Pandas UDF, performance | ~10% | Intermediate |
| `05_structured_streaming` | Output modes, triggers, checkpointing, watermarking | ~13% | Intermediate |
| `06_performance_optimization` | Caching, broadcast joins, AQE, skew, explain() | ~15% | Advanced |
| `07_pandas_api_on_spark` | pandas API, conversions, driver limits | ~5% | Intermediate |


## Docs & Troubleshooting

Platform-specific tips and known issues are in the [`docs/`](docs/) folder.

| Guide | Content |
|---|---|
| [`docs/windows-tips.md`](docs/windows-tips.md) | Port binding errors (Hyper-V reserved ranges), CRLF line endings, executable bits, Docker memory |

## Benchmark Workflow

```bash
# 1. Start cluster
make up-gluten

# 2. Generate data (~150 MB, scale=1)
make data

# 3. Open JupyterLab → run notebook 06
make notebook
```

## Gluten/Velox Notes

- `Q_window` (window function with large shuffle) is skipped in Gluten mode — known
  limitation of Gluten 1.6.0, tracked upstream
- `spark.sql.ansi.enabled=false` is set in `spark-defaults.conf` — Gluten does not
  support ANSI mode
- `spark.shuffle.sort.bypassMergeThreshold=0` — disables shuffle writers incompatible
  with Gluten's columnar batch serializer

## Makefile Reference

```bash
make init          # create directories, copy .env.example → .env
make build         # docker compose build
make up            # start vanilla cluster
make up-gluten     # start Gluten/Velox cluster
make up-kafka       # start Spark cluster with Kafka + Kafka UI
make down          # stop cluster
make down-kafka     # stop Kafka services
make logs          # tail spark-master logs
make logs-kafka     # tail Kafka logs
make status        # docker compose ps
make data          # generate TPC-H benchmark data
make clean         # stop + delete data
make nuke          # remove all images + builder cache
make notebook      # open JupyterLab in browser
make kafka-topics   # list Kafka topics
```
