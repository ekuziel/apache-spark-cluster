# Extensions Notebooks

JupyterLab and Spark-specific extension notebooks for productivity, validation, profiling, debugging and Spark metrics.

## Notebooks

| Notebook | Purpose |
|---|---|
| `00_extensions.ipynb` | JupyterLab 4.x productivity tools: widgets, progress bars, interactive tables/charts, SQL helpers, notebook diffs, output stripping, formatting and linting |
| `01_spark_extensions.ipynb` | Spark-specific helper libraries and built-in PySpark diagnostics for validation, data quality checks, profiling and DataFrame testing |
| `02_spark_debugging.ipynb` | Debugging patterns for query plans, joins, AQE, skew, caching, partitioning and runtime comparison |
| `03_sparkmeasure.ipynb` | sparkMeasure examples for stage metrics, task metrics, shuffle, joins, caching, AQE and skew |
| `04_sparkmeasure_explained.ipynb` | Explanation notebook for reading sparkMeasure metrics such as executor time, CPU time, GC, spill and shuffle read/write |

## Dependencies

Python helper packages are installed in the Docker image. `sparkMeasure` is a JVM/Spark dependency and is loaded as a Scala 2.13 JAR from `${SPARK_HOME}/jars/`.

## Recommended order

1. `00_extensions.ipynb`
2. `01_spark_extensions.ipynb`
3. `02_spark_debugging.ipynb`
4. `03_sparkmeasure.ipynb`
5. `04_sparkmeasure_explained.ipynb`
