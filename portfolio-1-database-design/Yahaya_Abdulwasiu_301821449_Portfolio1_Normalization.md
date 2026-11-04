# Database Normalization Report — ArewaConnect E-Commerce
**Student Name:** Yahaya Abdulwasiu  
**Student ID:** 301821449  
**Course:** MIT 8103 Advanced Database Systems  

---

## 1. Unnormalized Form (UNF)
The initial conceptual design combined customer details, store attributes, product information, payment references, and delivery data into a single flat transaction record:

`UNF_Order = (order_number, customer_full_name, customer_email, customer_phone, store_name, product_sku, product_name, category_name, price, quantity, delivery_address, payment_ref, payment_status, delivery_tracking_code)`

*Anomalies Identified:*
- **Insertion Anomaly:** Cannot record a new seller or category without placing an order.
- **Update Anomaly:** Updating a customer's phone number requires updating multiple order rows.
- **Deletion Anomaly:** Deleting an order erases product catalog details and store records.

My design approach for this portfolio was to reflect the way the business actually works rather than only following normalization theory. In ArewaConnect, users, sellers, products, purchases, and deliveries are different operational entities, so the database has to avoid duplicated data and keep historical records accurate. I separated customer information, store ownership, inventory, and order transactions so the system remains dependable as the platform grows and more sales are processed.

I also paid attention to the fact that product and address data can change independently of a completed sale. This matters because the platform needs to preserve the original transaction record while still allowing later updates to customer or store information without affecting the historical accuracy of past orders.

---

## 2. First Normal Form (1NF)
- **Rules Applied:** Atomicity enforced across attributes. Multi-valued line items extracted to bridge entities. Primary keys established.
- **Changes Made:** Separated `order_items` from `orders`. Created `addresses` table to hold user addresses separately.
- **Key Entities:** `users`, `seller_stores`, `categories`, `products`, `orders`, `order_items`.

---

## 3. Second Normal Form (2NF)
- **Rules Applied:** Removed partial functional dependencies (attributes depending on only part of a composite key).
- **Changes Made:**
  - `unit_price` in `order_items` is fixed at purchase time, while ongoing product attributes rely strictly on `product_id`.
  - Stock tracking separated into an `inventory` table dependent on `product_id`.

---

## 4. Third Normal Form (3NF) & Snapshot Pattern Design
- **Rules Applied:** Removed transitive dependencies ($X \rightarrow Y \rightarrow Z$).
- **Architectural Enhancements (Snapshots):**
  - **`shipping_address_snapshot` (JSONB):** Stores address at order time. Prevents future address updates by the customer from altering historical order tax/shipping records.
  - **`product_name_snapshot`:** Protects historical transaction accuracy if a seller renames a product later.
  - **`seller_stores` separation:** `seller_stores` depends on `owner_user_id`, decoupling multi-vendor store operations from standard user profiles.

---

## 5. Final 3NF Relations Architecture
- `users` ($\underline{\text{user\_id}}$, email, phone, role, status)
- `seller_stores` ($\underline{\text{store\_id}}$, owner_user_id*, name, state, city, status)
- `categories` ($\underline{\text{category\_id}}$, parent_category_id*, name, slug)
- `products` ($\underline{\text{product\_id}}$, store_id*, category_id*, sku, price, status)
- `inventory` ($\underline{\text{inventory\_id}}$, product_id*, quantity_on_hand, reorder_level)
- `addresses` ($\underline{\text{address\_id}}$, user_id*, state, city, street)
- `orders` ($\underline{\text{order\_id}}$, customer_id*, shipping_address_id*, total)
- `order_items` ($\underline{\text{order\_item\_id}}$, order_id*, product_id*, line_total)
- `payments` ($\underline{\text{payment\_id}}$, order_id*, reference, status)
- `deliveries` ($\underline{\text{delivery\_id}}$, order_id*, tracking_code, status)
- `reviews` ($\underline{\text{review\_id}}$, user_id*, product_id*, rating)
- `whatsapp_events` ($\underline{\text{event\_id}}$, user_id*, order_id*, event_type)
- `audit_logs` ($\underline{\text{audit\_id}}$, actor_user_id*, entity_type, action)