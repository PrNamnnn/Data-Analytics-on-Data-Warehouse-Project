# 📊 Customer & Product Analytics Project

## 📌 Overview

This project focuses on building an end-to-end analytics pipeline using structured data modeling and SQL-based reporting. It transforms raw transactional data into meaningful business insights related to **customers** and **products**.

The project follows a layered architecture (**Bronze → Silver → Gold**) and produces analytical reports that can support decision making in areas like customer retention, product performance, and revenue optimization.

---

## 🏗️ Project Structure

```
📁 dataset/
   ├── bronze/     → Raw data ingestion scripts
   ├── silver/     → Cleaned & transformed data
   ├── gold/       → Final analytical tables/views

📁 analysis/
   ├── report_eda_customers.sql
   ├── report_eda_products.sql
   ├── main_query.sql
```

---

## ⚙️ Data Architecture

### 🔹 Bronze Layer

* Stores raw, unprocessed data
* Acts as the source of truth
* No transformations applied

### 🔹 Silver Layer

* Data cleaning and standardization
* Handles nulls, duplicates, and inconsistencies
* Prepares data for analytics

### 🔹 Gold Layer

* Business-ready datasets
* Aggregated and optimized for reporting
* Used for final analysis and dashboards

---

## 📈 Reports & Analysis

### 👤 Customer Report

Provides insights into customer behavior and segmentation:

* Total Orders, Sales, Quantity
* Customer Lifespan
* Recency (last activity)
* Average Order Value (AOV)
* Customer Segments (VIP, Regular, New)

---

### 📦 Product Report

Analyzes product performance and revenue trends:

* Total Sales, Orders, Quantity
* Unique Customers per product
* Product Lifespan
* Recency (last sale)
* Average Selling Price
* Product Segmentation (High / Mid / Low performers)

---

### 📊 EDA (Exploratory Data Analysis)

* Separate SQL scripts for:

  * Customer analysis
  * Product analysis
* Helps identify trends, patterns, and anomalies

---

## 🚫 Data Availability

The dataset is not included in this repository due to its large size.
However, all transformation and reporting scripts are provided to reproduce the pipeline if data is available.

---

## 🛠️ Tech Stack

* SQL (T-SQL)
* Data Warehousing Concepts
* Layered Data Modeling (Bronze/Silver/Gold)

---

## 🎯 Key Learnings

* Designing scalable data pipelines
* Writing optimized SQL queries
* Building business-focused KPIs
* Structuring analytics projects professionally

---

## 🚀 Future Improvements

* Integration with Power BI / Tableau dashboards
* Automated ETL pipeline
* Advanced metrics (RFM, Cohort Analysis)
* Performance optimization using indexing

---

## 📬 Author

**Naman Prabhakar**

---

## 📎 Notes

This project is part of a learning journey in data analytics.
There may be minor imperfections, but it reflects practical understanding of real-world data workflows.
