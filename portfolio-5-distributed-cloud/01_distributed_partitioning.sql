-- =============================================================================
-- Course: MIT 8103 - Advanced Database Systems
-- Assessment: First Semester Continuous Assessment (Portfolio 5)
-- Student Name: Yahaya Abdulwasiu
-- Student ID: 301821449
-- Session: 2026/2027 Academic Session
-- Case Study: ArewaConnect E-commerce Platform
-- Engine: Serverless PostgreSQL (Neon Cloud)
-- Component: Portfolio 5 - Distributed and Cloud Database Implementation
-- =============================================================================

-- =============================================================================
-- 1. DECLARATIVE TABLE PARTITIONING FOR HIGH-VOLUME ORDERS
-- =============================================================================
-- Demonstrates horizontal range partitioning on the primary transaction table
-- to optimize query performance, enable partition pruning, and improve data maintenance.
--
-- Design rationale:
-- I selected monthly range partitioning for orders because this platform handles
-- a large and time-based transaction volume. Most operational queries are filtered
-- by date, especially for sales reports, delivery tracking, and dashboard analytics.
-- Partitioning by created_at allows PostgreSQL to prune irrelevant partitions and
-- reduce scan overhead while preserving the transactional integrity of the orders table.

DROP TABLE IF EXISTS orders_partitioned CASCADE;

CREATE TABLE orders_partitioned (
    order_id bigint GENERATED ALWAYS AS IDENTITY,
    user_id bigint NOT NULL,
    store_id bigint NOT NULL,
    order_number varchar(60) NOT NULL,
    total_amount numeric(12, 2) NOT NULL CHECK (total_amount >= 0),
    currency char(3) NOT NULL DEFAULT 'NGN',
    status varchar(20) NOT NULL CHECK (
        status IN (
            'pending',
            'paid',
            'processing',
            'shipped',
            'delivered',
            'cancelled'
        )
    ),
    created_at timestamp
    with
        time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT pk_orders_partitioned PRIMARY KEY (order_id, created_at)
)
PARTITION BY
    RANGE (created_at);

-- =============================================================================
-- 2. CREATE MONTHLY PARTITION TABLES (Q3 & Q4 2026)
-- =============================================================================

-- Partition for September 2026
CREATE TABLE orders_y2026m09 PARTITION OF orders_partitioned FOR
VALUES
FROM ('2026-09-01 00:00:00+00') TO ('2026-10-01 00:00:00+00');

-- Partition for October 2026
CREATE TABLE orders_y2026m10 PARTITION OF orders_partitioned FOR
VALUES
FROM ('2026-10-01 00:00:00+00') TO ('2026-11-01 00:00:00+00');

-- Partition for November 2026
CREATE TABLE orders_y2026m11 PARTITION OF orders_partitioned FOR
VALUES
FROM ('2026-11-01 00:00:00+00') TO ('2026-12-01 00:00:00+00');

-- Partition for December 2026
CREATE TABLE orders_y2026m12 PARTITION OF orders_partitioned FOR
VALUES
FROM ('2026-12-01 00:00:00+00') TO ('2027-01-01 00:00:00+00');

-- Default partition for out-of-range dates
CREATE TABLE orders_default PARTITION OF orders_partitioned DEFAULT;

-- =============================================================================
-- 3. INDEXES ON PARTITIONED TABLES
-- =============================================================================
-- Indexes are automatically propagated to all current and future child partitions.

CREATE INDEX idx_orders_part_user ON orders_partitioned (user_id);

CREATE INDEX idx_orders_part_store_status ON orders_partitioned (store_id, status);

CREATE INDEX idx_orders_part_created ON orders_partitioned (created_at);

-- =============================================================================
-- 4. SEED SAMPLE TRANSACTION DATA ACROSS PARTITIONS
-- =============================================================================

INSERT INTO
    orders_partitioned (
        user_id,
        store_id,
        order_number,
        total_amount,
        status,
        created_at
    )
VALUES (
        1,
        1,
        'ORD-202609-001',
        25000.00,
        'delivered',
        '2026-09-15 10:30:00+00'
    ),
    (
        1,
        1,
        'ORD-202609-002',
        12500.00,
        'delivered',
        '2026-09-28 14:20:00+00'
    ),
    (
        1,
        1,
        'ORD-202610-001',
        45000.00,
        'paid',
        '2026-10-05 09:15:00+00'
    ),
    (
        1,
        1,
        'ORD-202610-002',
        8000.00,
        'processing',
        '2026-10-18 16:45:00+00'
    ),
    (
        1,
        1,
        'ORD-202611-001',
        30000.00,
        'pending',
        '2026-11-02 11:00:00+00'
    );

-- =============================================================================
-- 5. VERIFY PARTITION DISTRIBUTION AND PRUNING
-- =============================================================================

-- Query 5.1: Confirm Row Counts per Child Partition
SELECT 
    tableoid::regclass AS partition_name, 
    COUNT(*) AS total_orders,
    MIN(created_at) AS earliest_order,
    MAX(created_at) AS latest_order
FROM orders_partitioned
GROUP BY tableoid
ORDER BY partition_name;

-- Query 5.2: Verify Partition Pruning via Execution Plan
-- PostgreSQL engine will scan ONLY the orders_y2026m10 partition and skip all others.
-- I used this query to confirm that the date pruning logic works as expected for a
-- single monthly slice of the order history. This is important for workload efficiency
-- because real sales reports and dashboards usually request a narrow time range.
EXPLAIN ANALYZE
SELECT
    order_id,
    order_number,
    total_amount,
    status,
    created_at
FROM orders_partitioned
WHERE
    created_at >= '2026-10-01 00:00:00+00'
    AND created_at < '2026-11-01 00:00:00+00';