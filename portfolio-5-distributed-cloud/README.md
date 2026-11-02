# Portfolio 5: Distributed and Cloud Database Exercise

**Course:** MIT 8103 - Advanced Database Systems  
**Academic Session:** 2026/2027 Academic Session (First Semester)  
**Student Name:** Yahaya Abdulwasiu  
**Student ID:** 301821449  
**Case Study:** ArewaConnect E-Commerce Platform  
**Database Architecture:** Cloud Serverless PostgreSQL (Neon DB on AWS)  

---

## 1. Executive Summary & Case Study Overview

**ArewaConnect** is a growing e-commerce platform that connects Northern Nigerian vendors, artisans, and merchants with customers across the country. As the business expands, the database has to handle larger transaction volumes, more concurrent access, and a higher demand for fast reporting during busy sales periods. This makes cloud scalability and efficient data distribution a major part of the system design.

This module demonstrates the distributed and cloud database architecture I used to support ArewaConnect. The solution is based on **Neon Serverless PostgreSQL** hosted on AWS (`us-east-2`) and includes:
- Decoupled cloud compute and storage architecture.
- Connection pooling and scaling.
- Active read-replication strategies.
- Declarative range table partitioning for high-volume transactions.
- Formal CAP theorem analysis.

I chose this approach because the platform has both transactional and analytical workloads. Orders, payments, and inventory updates require consistency, but sales reporting and operational dashboards also need fast data access. A cloud-based database structure helps balance those needs without putting unnecessary pressure on one server component.

---

## 2. Cloud Database Architecture (Neon Serverless PostgreSQL)

ArewaConnect uses a modern serverless PostgreSQL deployment on Neon Cloud, separating compute logic from persistent storage. I chose this architecture because the platform must support growth in traffic, high transaction volume, and consistent performance without the operational burden of managing a dedicated physical database server. The separation of compute and storage allows the system to scale more efficiently while keeping the data layer resilient and easier to maintain.

My design decision for the distributed database layer is centered on scalability and time-based access patterns. Order records are generated continuously, but most business queries are filtered by date or reporting period. This makes range partitioning a practical and effective way to reduce unnecessary table scans and maintain fast query performance for the most common workloads.

+---------------------------------+
                           |   Application / Clients / Web   |
                           +---------------------------------+
                                           |
                                           v
                           +---------------------------------+
                           |  PgBouncer Connection Pooler    |
                           |    (Neon Cloud Proxy - TLS)     |
                           +---------------------------------+
                                           |
                                           v
                   +-------------------------------------------------+
                   |           Stateless Compute Node                |
                   |   (Auto-scaling 0.25 to 4 Compute Units)       |
                   +-------------------------------------------------+
                                           |
                    +----------------------+----------------------+
                    | Streaming WAL                               | Page Fetch
                    v                                             v
   +---------------------------------+           +---------------------------------+
   |      Safekeeper Consensus       |           |          Page Server            |
   |      (Replication Log Layer)    |           |   (NVMe Cache)