# Changelog

## [4.0.0] — 2026-04-08

### Changed
- **Spark 4.0.2** (Scala 2.13, Java 17) — Gluten 1.6.0 fully supports Spark 4.0.x
- **Gluten 1.6.0** — official Apache binary release from `dlcdn.apache.org/gluten/1.6.0/apache-gluten-1.6.0-bin-spark-4.0.tar.gz`
- **Iceberg 1.10.1** — `iceberg-spark-runtime-4.0_2.13`
- **Delta 4.0.1** — `delta-spark_2.13`
- Removed `pyspark` pip package — using Spark image built-in `/opt/spark/python/` via `PYTHONPATH`
- Added `py4j` pip package (standalone dependency for PySpark Python bindings)
- `delta-spark` installed with `--no-deps` to prevent pip pulling a duplicate `pyspark`
- Note: Gluten 1.6.0 is tested against Spark 4.0.1; running on 4.0.2 produces a harmless warning

---

## [3.0.0] — 2026-04-07

### Changed
- Gluten upgrade: 1.4.0 → 1.6.0
- Download URL updated to `dlcdn.apache.org/gluten/` (official Apache CDN)

---

## [2.0.0] — 2026-04-07

### Changed
- Spark 3.5.8 → 4.0.x migration attempt (superseded by 4.0.0 release above)

---

## [1.0.0] — 2026-04-07

### Added
- Initial release: Spark cluster with Gluten/Velox, Iceberg, Delta, JupyterLab
- Docker Compose setup with master, 2 workers, history server, notebook
- TPC-H style benchmark notebook (vanilla vs Gluten/Velox)
