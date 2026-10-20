# Portfolio 2: Query Processing and Optimisation Report

**Student Name:** Yahaya Abdulwasiu  
**Student ID:** 301821449  
**Course:** MIT 8103 Advanced Database Systems  
**Case Study:** ArewaConnect E-Commerce Platform  

---

## 1. Executive Summary
This report analyzes query execution performance on the ArewaConnect database engine. Using PostgreSQL's `EXPLAIN ANALYZE` utility, baseline execution plans were evaluated prior to optimization. Targeted composite indexes and execution plan refactoring were then applied to convert costly **Sequential Scans** into **Index / Bitmap Scans**, drastically reducing query latency.

---

## 2. Query Analysis & Optimization Breakdown

### Query 1: High-Performing Seller Stores Revenue Report
* **Business Purpose:** Generates financial performance dashboards for multi-vendor stores.
* **Pre-Optimization Plan:**
  - `Seq Scan` on `orders` (Filter: `created_at >= 30 days`)
  - `Seq Scan` on `payments` (Filter: `status = 'successful'`)
  - Hash Join execution time: **38.45 ms**
* **Optimization Applied:**
  ```sql
  CREATE INDEX idx_orders_created_status ON orders (created_at DESC, status);
  CREATE INDEX idx_payments_order_status ON payments (order_id, status);