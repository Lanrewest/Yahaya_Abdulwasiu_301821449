# Portfolio 5: Distributed and Cloud Database Exercise

**Course:** MIT 8103 - Advanced Database Systems  
**Academic Session:** 2026/2027 Academic Session (First Semester)  
**Student Name:** Yahaya Abdulwasiu  
**Student ID:** 301821449  
**Case Study:** ArewaConnect E-Commerce Platform  
**Database Architecture:** Cloud Serverless PostgreSQL (Neon DB on AWS)  

---

## 1. Executive Summary & Case Study Overview

**ArewaConnect** is an e-commerce platform connecting Northern Nigerian vendors, crafts artisans, and merchants with nationwide consumers. As traffic grows rapidly, managing high concurrent database access, ensuring operational resilience during peak shopping periods, and sustaining rapid read/write throughput are essential.

This module demonstrates the distributed and cloud database architecture supporting ArewaConnect. The deployment leverages **Neon Serverless PostgreSQL** hosted on AWS (`us-east-2`), incorporating:
- Decoupled cloud compute and storage architecture.
- Connection pooling and scaling.
- Active read-replication strategies.
- Declarative range table partitioning for high-volume transactions.
- Formal CAP theorem analysis.

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