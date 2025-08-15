# E-Commerce-Platform

NOTE: This project is for learning purposed and first time building ELT Pipeline using tech stack like dbt, MinIO, Airflow, DuckDB. Thanks !

# Project Introduction
This project implements a ELT Pipeline using Modern Data Stack tools, and the dataset used in the project is the Olist E-Commerce datasets. I adopt the idea of Kimball and dbt docs to design a architect for this project. If the architect is done wrongly, so any suggests and help wil be appreciated. Thanks !

Datasets can be found from [here][https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce]

As the ELT Pipeline, first the data is extract and load then get thourgh the transformation stage. Here is the breakdown for architect.
- Staging Layer: Where the data is raw. The table structure at this stage is correspond to source system table "as-is"
- Intermediate Layer: This is where the data from Staging is matched, joined, cleaning and enriched. At this stage, we will provide an "enterprise view" but not at the ready-for-query.
- Mart layer: At this stage, the data will be through the transformation stage, it is organized into the granularity-specific at this point. Each table in this stage represent for a granularity it presents. The Mart layer use de-normalized, normalized and also read-optimized (via Kimball, dbt,....)

# Architecture
## Staging layer
You can found the staging layer in the dbt project (via ecommerce_dbt), the staging is 1-1 to source data. As in dbt's documentation staging models should have a 1-1 relationship to the source system. Performed some basic cleaning as cast type or trimming,...etc.

## Intermediate Layer
This layer will use the downstream at staging above. At here the data is then cleaning with missing/null value, deduplication,enriched... so now the data is on-ready for the last layer.

## Mart layer 
This is the layer where everything comes together and we start to arrange all of our staging models into full-fledged cells that have identity and purpose.
All the models in this folder conform our Kimball-like dimensional model. Following Kimball's guidelines, the following changes made to the layer
- Removed the orders table, keep only the orders_items only: The initial raw data has two tables that represent the sales pattern included orders and orders_items, per Kimball we will lower the grain down to the items level. We use the 'degenerate dimension' for the attributes or keys that been attached for the orders tables

- per Kimball design tip: "This model represents the data relationships from the transaction header/line source system. But we’ve abandoned the operational mentality surrounding a header file. The header’s natural key, the transaction number, is still present in our design, but it’s treated as a degenerate dimension."

- You can find the documentation about this on [here][https://www.kimballgroup.com/2007/10/design-tip-95-patterns-to-avoid-when-modeling-headerline-item-transactions/], also the page for design [modelling dimensional][https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/].





