# Portfolio 2: Query Processing and Optimisation Report

**Student Name:** Yahaya Abdulwasiu  
**Student ID:** 301821449  
**Course:** MIT 8103 Advanced Database Systems  
**Case Study:** ArewaConnect E-Commerce Platform  

---

## 1. Executive Summary
This report looks at how I improved query performance for the ArewaConnect platform using PostgreSQL's `EXPLAIN ANALYZE` tool. I started by checking the execution plans to identify which database paths were doing unnecessary work and which queries were scanning too much data. From there, I added targeted composite indexes and adjusted the query structure so the engine could use more efficient access paths instead of processing a much larger dataset than needed.

The main issue in practice was the repeated load from business reporting. Seller dashboards, order summaries, and recent transaction views are often generated daily, and they usually depend on date ranges, status filters, and joins across transaction tables. I focused on those workload patterns because they reflect how the business actually uses the system, and they are the areas where performance issues become noticeable to users.

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