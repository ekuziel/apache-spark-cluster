# Patterns

This folder contains reusable Spark implementation patterns.

## 01 — Pydantic + Spark contracts

Notebook:

```text
patterns/01_pydantic_spark_contracts.ipynb
```

This is a pattern, not a Spark runtime library.

Pydantic is used for:

- data contracts
- edge validation
- config validation
- schema documentation
- test fixtures
- small sample validation

Spark is used for:

- distributed reads
- schema enforcement
- transformations
- large-scale validation
- quarantine handling
- writes to Parquet / Delta-style layers

## Important rule

Do not validate every Spark row through Pydantic UDFs.

Use Pydantic at the edges and Spark expressions at scale.

## Pattern overview

```text
Pydantic model
  -> explicit Spark StructType schema
  -> Spark read with schema
  -> Spark quality checks
  -> valid dataset + quarantine dataset
  -> write outputs
```

## Example model

The included notebook demonstrates a `CustomerEvent` contract with:

- required string fields
- nullable numeric field
- timestamp field
- schema conversion notes
- valid and invalid sample records
- Spark-side validation rules
- quarantine output

## Recommended usage

Use this pattern for topics such as:

- Bronze ingestion contracts
- API-to-Spark handoff
- streaming input contracts
- medallion architecture validation
- test data fixtures
- documentation of expected input shape
