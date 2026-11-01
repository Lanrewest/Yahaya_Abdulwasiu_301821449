# Portfolio 4: NoSQL Integration and Distributed Database Strategy
**Student Name:** Yahaya Abdulwasiu  
**Student ID:** 301821449  
**Course:** MIT 8103 - Advanced Database Systems  
**Case Study:** ArewaConnect E-Commerce Platform  

---

## 1. Architectural Paradigms: Relational vs. NoSQL

My reasoning for this portfolio was to separate the data requirements of the business by workload type. An online marketplace like ArewaConnect does not require the same database technology for every task. Transactional integrity is essential for payments and orders, while flexible product metadata and high-speed cache access are better handled using document and key-value stores. This is why I designed the solution as a hybrid system rather than forcing everything into a single database model.

| Dimension | PostgreSQL (Core RDBMS) | MongoDB (Document Store) | Redis (Key-Value Store) |
| :--- | :--- | :--- | :--- |
| **Primary Domain** | Orders, Financial Ledgers, Inventory Control | Unstructured Catalog, Reviews, Media Metadata | User Sessions, Cart State, Rate Limiting |
| **Data Structure** | Normalized 13-Table Schema | Hierarchical JSON/BSON Documents | In-Memory Hash Maps & Strings |
| **Consistency Model** | ACID (Strict Immediate Consistency) | BASE (Eventual Consistency / Configurable) | In-memory Speed (Volatile/Persisted) |
| **Scaling Mechanism** | Vertical Scaling + Read-Replicas | Horizontal Sharding (Shared-Nothing) | Primary-Replica Cluster / Sharding |

---

## 2. Polyglot Persistence Strategy for ArewaConnect

ArewaConnect uses a **Polyglot Persistence Architecture**, matching individual system workload characteristics with optimal database engines:

1. **PostgreSQL (RDBMS - Financial Core):** Enforces ACID properties for transaction processing, order history, payment ledgers, and vendor commission tracking where zero data loss is required.
2. **MongoDB (Document Store - Catalog Extension):** Manages dynamic product catalog schemas where different product categories (e.g., textiles, agricultural produce, artisanal crafts) require distinct attributes without requiring schema migrations in SQL.
3. **Redis (Key-Value Cache - Speed Layer):** Serves as an in-memory caching layer for hot inventory balances and user authentication tokens to shield PostgreSQL from peak read workloads.

---

## 3. Distributed Database Architecture & CAP Theorem

### CAP Theorem Trade-Off Analysis
* **Core Ledger (PostgreSQL):** Prioritizes **Consistency and Partition Tolerance (CP)**. During network partitions, transactions are rejected rather than risking inconsistent stock levels or double-spending.
* **Catalog & Caching (MongoDB/Redis):** Prioritizes **Availability and Partition Tolerance (AP)**. Reads continue even if sync delays occur between regional nodes.

### Distributed Scaling & High Availability Strategies
* **Multi-Region Read Replication:** Active database read-replicas deployed in regional hubs (Lagos, Abuja, Kano) reduce query latency for localized buyers and vendors.
* **Declarative Table Partitioning:** Range-partitioning applied to historical transaction tables (`orders`, `audit_logs`) based on time ranges (`created_at`) maintains query index performance across multi-million row datasets.
* **Cloud Infrastructure (Neon / Managed PostgreSQL):** Utilizes serverless auto-scaling compute instances connected to decoupled storage nodes to scale during flash sales.