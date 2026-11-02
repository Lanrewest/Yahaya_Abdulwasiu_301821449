# Portfolio 2: Query Processing and Optimisation Report

**Student Name:** Yahaya Abdulwasiu  
**Student ID:** 301821449  
**Course:** MIT 8103 Advanced Database Systems  
**Case Study:** ArewaConnect E-Commerce Platform  

---

## 1. Executive Summary
This report looks at how query performance was improved for the ArewaConnect platform using PostgreSQL's `EXPLAIN ANALYZE` tool. I started by examining the baseline execution plans to identify which queries were using expensive scan operations and where the database was doing extra work. After that, I applied targeted composite indexes and adjusted the query structure so the database could use more efficient execution paths instead of reading larger volumes of data than necessary.

From a practical point of view, the biggest issue was the impact of repeated business reporting. Seller dashboards, order summaries, and recent transaction reports are usually generated often, and they frequently depend on date ranges, order status checks, and joins across transaction tables. I focused the optimization effort on these real workload patterns so the system could respond faster during daily operations while still keeping the results accurate and consistent.

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