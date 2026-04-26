# Powerful Spark 4.x Features

Feature showcase notebook for modern Apache Spark 4.x capabilities.

| Notebook | What you will learn |
|---|---|
| `01-powerful-spark-4.x-features.ipynb` | End-to-end overview of Spark 4.x features including AQE + Dynamic Partition Pruning, Pandas API on Spark, Delta Lake (time travel, optional Z-Order), Structured Streaming (`foreachBatch`, `availableNow`), Apache Iceberg (schema evolution, hidden partitioning), RAPIDS GPU detection, Spark Connect (remote execution), and MLlib pipelines with optional ONNX export |

## Environment

The notebook is configured for the local Docker Compose Spark cluster:

```python
MASTER = "spark://spark-master:7077"
DATA_DIR = "/workspace/data"
```

These can be overridden via environment variables:

```bash
SPARK_MASTER=spark://spark-master:7077
DATA_DIR=/workspace/data
SPARK_CONNECT_REMOTE=sc://spark-connect:15002
GLUTEN_ENABLED=false
```

## Optional Dependencies

Delta Lake, Iceberg, RAPIDS, Spark Connect, and ONNX sections are guarded with `try/except`.

If a dependency or service is not available, the notebook skips the section and continues execution.

To enable full functionality, required Spark packages/JARs must be available on the classpath (via Docker image or Spark configuration).