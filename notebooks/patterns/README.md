# Patterns & Medallion

| # | Notebook | Topics |
|---|---|---|
| 01 | `01_pydantic_spark_contracts.ipynb` | Data contracts, validation, schema enforcement |
| 02 | `02_transform_pattern.ipynb` | Reusable transformations, composable logic |
| 03 | `03_config_driven_pipeline.ipynb` | Config-based pipeline behavior |
| 04 | `04_rule_engine_pattern.ipynb` | Validation rules, error tagging |
| 05 | `05_column_mapping_pattern.ipynb` | Column renaming, mapping strategies |
| 06 | `06_audit_columns_pattern.ipynb` | Metadata, lineage, processing timestamps |
| 07 | `07_data_contract_check_pattern.ipynb` | Contract validation, schema checks |
| 08 | `08_reusable_pipeline_function.ipynb` | Function-based pipelines |
| 09 | `09_multi_output_pattern.ipynb` | Multiple outputs (silver, quarantine, metrics) |
| 10 | `10_metrics_observability_pattern.ipynb` | Metrics, monitoring, counts |
| 11 | `11_schema_drift_guard.ipynb` | Schema evolution protection |
| 12 | `12_idempotent_upsert_pattern.ipynb` | Safe upserts, deduplication |
| 13 | `13_partitioning_strategy_pattern.ipynb` | Partitioning, layout optimization |
| 14 | `14_cache_persist_pattern.ipynb` | Cache vs persist usage |
| 15 | `15_window_pattern.ipynb` | Window functions, ranking, lag |
| 16 | `16_scd2_pattern.ipynb` | Slowly changing dimensions |
| 17 | `17_small_file_problem_pattern.ipynb` | File size optimization, coalesce vs repartition |
| 18 | `18_checkpoint_pattern.ipynb` | Lineage control, checkpointing |
| 19 | `19_join_optimization_pattern.ipynb` | Filter-before-join optimization |
| 20 | `20_data_skew_pattern.ipynb` | Skew handling, salting |
| 21 | `21_broadcast_vs_shuffle_pattern.ipynb` | Join strategies |
| 22 | `22_pipeline_wrapper_pattern.ipynb` | End-to-end pipeline wrapper |

---

## Medallion

| # | Notebook | Topics |
|---|---|---|
| 00 | `00_basic.ipynb` | Basic medallion flow (bronze → silver → gold) |
| 01 | `01_bronze_to_silver_quality.ipynb` | Validation, normalization |
| 02 | `02_silver_to_gold_aggregation.ipynb` | Aggregations, business metrics |
| 03 | `03_silver_quality_dedup_quarantine.ipynb` | Deduplication, quarantine |
| 04 | `04_gold_star_schema.ipynb` | Star schema, analytics layer |
