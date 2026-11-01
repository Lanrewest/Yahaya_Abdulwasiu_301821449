# Portfolio 3: Transactions and Concurrency Control Report

**Student Name:** Yahaya Abdulwasiu  
**Student ID:** 301821449  
**Course:** MIT 8103 Advanced Database Systems  
**Case Study:** ArewaConnect E-Commerce Platform  

---

## 1. Executive Summary
This report documents the transaction handling and concurrency control mechanics implemented for the ArewaConnect multi-vendor e-commerce database engine. Using explicit PostgreSQL transaction controls (`BEGIN`, `COMMIT`, `SAVEPOINT`, `ROLLBACK`), row-level locking (`FOR UPDATE`), and isolation levels (`REPEATABLE READ`), the system guarantees full ACID compliance during high-concurrency ordering workflows.

I approached this portfolio from the perspective of a live e-commerce system where multiple buyers, sellers, and staff members can act at the same time. In such an environment, the greatest risk is not software failure alone but inconsistent inventory and duplicated transaction outcomes. My design therefore emphasizes locking, transaction boundaries, and clear isolation rules so that each order is processed consistently even when concurrent activity increases during peak buying periods.

---

## 2. ACID Properties Verification

### A. Atomicity
All steps of order processing—inventory deduction, order creation, line-item insertion, payment logging, and audit tracking—are wrapped inside an explicit `BEGIN ... COMMIT` block. If any step fails (e.g., negative stock constraint violation), PostgreSQL automatically aborts the entire transaction block, leaving the database state untouched.

### B. Consistency
Integrity constraints defined in the schema strictly enforce business rules across transactions:
- `CHECK (quantity_on_hand >= 0)` prevents stock from dropping below zero.
- `CHECK (total = subtotal + delivery_fee)` enforces monetary balancing.
- `FOREIGN KEY (...) ON DELETE CASCADE` maintains relational integrity.

### C. Isolation
PostgreSQL defaults to `READ COMMITTED` isolation, preventing **Dirty Reads**. For sensitive operational reports, transactions are escalated to `REPEATABLE READ`, establishing a point-in-time snapshot that shields queries from concurrent modifications.

### D. Durability
PostgreSQL's Write-Ahead Logging (WAL) guarantees that once a transaction executes `COMMIT`, all modifications are persisted to non-volatile disk storage and survive database host crashes.

---

## 3. Concurrency Anomaly Mitigation Matrix

| Concurrency Anomaly | Problem Scenario | ArewaConnect Mitigation Mechanism |
| :--- | :--- | :--- |
| **Dirty Read** | Session B reads uncommitted price changes made by Session A. | Mitigated by PostgreSQL default `READ COMMITTED` isolation level. |
| **Lost Update** | Two buyers simultaneously buy the last item, overwriting stock values without reading intermediate states. | Mitigated using explicit **Pessimistic Row Locking** (`SELECT ... FOR UPDATE`). |
| **Non-Repeatable Read** | Session A re-reads product price mid-transaction and sees a change committed by Session B. | Mitigated by setting `TRANSACTION ISOLATION LEVEL REPEATABLE READ`. |
| **Phantom Read** | Session A queries order counts, Session B inserts a new order, and Session A re-queries getting a different count. | Mitigated by `REPEATABLE READ` snapshot isolation. |

---

## 4. Live Terminal Concurrency Simulation Steps

To capture screenshot evidence for the `portfolio-3-transactions-concurrency/screenshots/` folder, execute two side-by-side terminal sessions (`psql`):

### Terminal Session A (Customer 1):
```sql
BEGIN;
SELECT quantity_on_hand FROM inventory WHERE product_id = 1 FOR UPDATE;
-- [DO NOT COMMIT YET]