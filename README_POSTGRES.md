README: Data Warehouse (PostgreSQL + pgAdmin + Power BI)

Overview
--------
This repository contains the SQL artifacts and example datasets for a small data-warehouse implemented using a Bronze → Silver → Gold layered architecture. This README documents a pgAdmin-first workflow to:

- Create the database & schemas
- Create Bronze / Silver tables
- Load raw CSV data into Bronze
- Run Silver transformations (cleaning & standardization)
- Create Gold views (business-facing dimensions and facts)
- Run quality checks
- Connect Power BI to the Gold views and build dashboards

Conventions
-----------
- Database name used in this guide: `datawarehouse` (lowercase)
- Schemas: `bronze`, `silver`, `gold`
- SQL scripts live under `scripts/` and tests under `tests/`

Prerequisites
-------------
- PostgreSQL 11+ installed and running
- pgAdmin (desktop or web) connected to the PostgreSQL server
- Power BI Desktop (for dashboarding; optional)
- Datasets available in `datasets/` (CSV files provided in the repo)

1) Create database and schemas (pgAdmin)
---------------------------------------
GUI steps (pgAdmin):

1. Open pgAdmin and connect to your server.
2. Right-click "Databases" → Create → Database...; name it `datawarehouse`.
3. Expand the new database, right-click "Schemas" → Create → Schema... and add: `bronze`, `silver`, `gold`.

SQL (Query Tool) alternative:

```sql
-- Run in Query Tool (connect to 'postgres' to create DB, then reconnect to 'datawarehouse')
CREATE DATABASE datawarehouse;
-- then connect to datawarehouse and run:
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
```

2) Create Bronze tables
------------------------
Open `scripts/bronze/ddl_bronze.sql` in pgAdmin's Query Tool and inspect the DDL. The file contains CREATE TABLE statements but originates from SQL Server — it includes T-SQL conditionals. Recommended options:

- Edit the file to add `DROP TABLE IF EXISTS bronze.<table> CASCADE;` before each CREATE TABLE and then execute the script in the Query Tool.
- Or create tables via pgAdmin GUI (Schemas → bronze → Tables → Create → Table...).

If you want, I can provide a Postgres-ready version `scripts/bronze/ddl_bronze_postgres.sql` that is idempotent.

3) Load CSVs into Bronze (pgAdmin Import)
----------------------------------------
Recommended (GUI): use pgAdmin's Import/Export dialog — it reads the CSV from your client machine and avoids server file-permission issues.

Steps:
1. In pgAdmin, expand `datawarehouse` → Schemas → bronze → Tables.
2. Right-click the target table (e.g., `bronze.crm_cust_info`) → Import/Export.
3. Set: Filename → `datasets/source_crm/cust_info.csv` (or absolute path); Format → CSV; Header → checked; Delimiter → `,`.
4. Click Import.

Repeat for the other Bronze tables. If column order differs, either map columns in the dialog or import into a staging table and transform.

Server-side SQL alternative (server must have filesystem access):

```sql
COPY bronze.crm_cust_info FROM 'C:/full/path/to/datasets/source_crm/cust_info.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
```

4) Run Silver transformations (bronze → silver)
--------------------------------------------
Open `scripts/silver/proc_load_silver.sql` in pgAdmin's Query Tool connected to `datawarehouse`, review any assumptions (date formats, dedup logic), and execute the file. The script performs TRUNCATE + INSERT operations that populate the `silver` schema.

Notes:
- Date parsing in the script uses `to_date(..., 'YYYYMMDD')` for integer-style dates. Adjust if your CSVs use different formats.

5) Create Gold views (presentation layer)
----------------------------------------
Open `scripts/gold/ddl_gold.sql` in the Query Tool and execute. The script uses `DROP VIEW IF EXISTS` / `CREATE OR REPLACE VIEW` so it is safe to re-run.

Important: the current views generate surrogate-like keys with `ROW_NUMBER()` inside the view. These are not stable between query executions. For stable surrogate keys, persist dimensions into physical tables with sequence-based keys.

6) Run quality checks
---------------------
Open and execute the files in `tests/` (for example `tests/quality_checks_silver.sql`) in the Query Tool. 
Investigate any returned rows — they indicate quality issues (duplicates, invalid dates, inconsistent values).

7) Connect Power BI to PostgreSQL
--------------------------------
Power BI Desktop → Home → Get Data → PostgreSQL database.

Connection details:
- Server: <your_postgres_host>
- Database: datawarehouse
- Authentication: provide PostgreSQL username/password

Select the `gold` schema views (e.g., `gold.dim_customers`, `gold.dim_products`, `gold.fact_sales`) as import or DirectQuery sources.

8) Dashboard design guidance (Power BI)
--------------------------------------
Suggested pages and KPIs:

- Executive Summary: total sales, total orders, average order value, period-over-period growth.
- Product Performance: sales by category/subcategory/product, top N products, margin analysis.
- Customer Insights: sales by country, gender, marital status, customer acquisition trends.
- Orders & Delivery: order volumes, shipping delays, late shipments.
- Profitability: total profit, profit margin %, profitability by product and geography.

Sample query for monthly sales (use in Power BI native query or pgAdmin):

```sql
SELECT date_trunc('month', order_date) AS month, SUM(sales_amount) AS total_sales
FROM gold.fact_sales
GROUP BY 1
ORDER BY 1;
```



