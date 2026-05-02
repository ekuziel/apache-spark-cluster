# SCD Patterns

Slowly Changing Dimension examples for Apache Spark.

## Notebooks

| # | Notebook | Type | What it demonstrates |
|---|---|---|---|
| 00 | `00_scd_type_0_retain_original.ipynb` | SCD Type 0 | Fixed attributes; changes are ignored |
| 01 | `01_scd_type_1_overwrite.ipynb` | SCD Type 1 | Overwrite current values; no history |
| 02 | `02_scd_type_2_history.ipynb` | SCD Type 2 | Full history with `valid_from`, `valid_to`, `is_current` |
| 03 | `03_scd_type_3_previous_value.ipynb` | SCD Type 3 | Current value + previous value columns |
| 04 | `04_scd_type_4_history_table.ipynb` | SCD Type 4 | Current table + separate history table |
| 06 | `06_scd_type_6_hybrid.ipynb` | SCD Type 6 | Hybrid Type 1 + Type 2 + Type 3 |

## Model

```text
SCD Type 0 = keep original value
SCD Type 1 = overwrite value
SCD Type 2 = add new version row
SCD Type 3 = keep current + previous value
SCD Type 4 = current table + history table
SCD Type 6 = Type 1 + Type 2 + Type 3 hybrid
```