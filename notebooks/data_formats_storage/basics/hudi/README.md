# Apache Hudi

Complete guide to Apache Hudi from basic table creation to production-ready data lake patterns.

| # | Notebook | Topics |
|---|---|---|
| 01 | `01_hudi_setup_basic_crud.ipynb` | What Hudi is, Copy-On-Write (COW) tables, table creation, insert & read, Hudi metadata columns, basic table structure |
| 02 | `02_hudi_upserts_duplicate_handling.ipynb` | Upserts (insert + update), handling duplicate keys, precombine logic, latest record selection, time travel basics |
| 03 | `03_hudi_deletes_soft_deletes.ipynb` | Hard deletes vs soft deletes, delete operation, tombstone records, implementing logical delete patterns |
| 04 | `04_hudi_merge_on_read_compaction.ipynb` | Merge-On-Read (MOR) tables, delta logs vs base files, snapshot vs read-optimized queries, inline compaction |
| 05 | `05_hudi_schema_evolution.ipynb` | Schema evolution, adding columns, backward compatibility, handling nulls for old records, safe schema changes |
| 06 | `06_hudi_time_travel_audit.ipynb` | Time travel with commit instants, audit trail patterns, incremental history, comparing business vs commit time |
| 07 | `07_hudi_incremental_queries_cdc.ipynb` | Incremental queries, CDC pattern, begin/end commit logic, low isolation reads, building downstream pipelines |
| 08 | `08_hudi_partitioning_data_skipping.ipynb` | Partitioning strategies, metadata table, data skipping, partition pruning, EXPLAIN plan verification |
| 09 | `09_hudi_structured_streaming.ipynb` | Structured Streaming sink, continuous upserts, checkpointing, micro-batch processing, streaming → Hudi |
| 10 | `10_hudi_production_best_practices_monitoring.ipynb` | Production configs, performance tuning, metadata indexing, commit monitoring, cleaning, scaling, debugging |