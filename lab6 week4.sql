USE sakila;

-- Step 1:
DROP VIEW IF EXISTS customer_rental_summary;

CREATE VIEW customer_rental_summary AS
SELECT
  c.customer_id,
  c.first_name,
  c.last_name,
  c.email,
  COALESCE(COUNT(r.rental_id), 0) AS rental_count
FROM customer c
LEFT JOIN rental r
  ON r.customer_id = c.customer_id
GROUP BY
  c.customer_id, c.first_name, c.last_name, c.email;


-- Step 2: 
DROP TEMPORARY TABLE IF EXISTS customer_payments_temp;

CREATE TEMPORARY TABLE customer_payments_temp AS
SELECT
  v.customer_id,
  COALESCE(SUM(p.amount), 0) AS total_paid
FROM customer_rental_summary v
LEFT JOIN payment p
  ON p.customer_id = v.customer_id
GROUP BY v.customer_id;


-- Step 3: 
WITH customer_summary AS (
  SELECT
    v.customer_id,
    CONCAT(v.first_name, ' ', v.last_name) AS customer_name,
    v.email,
    v.rental_count,
    t.total_paid
  FROM customer_rental_summary v
  LEFT JOIN customer_payments_temp t
    ON t.customer_id = v.customer_id
)
SELECT
  customer_name,
  email,
  rental_count,
  total_paid,
  CASE
    WHEN rental_count > 0 THEN ROUND(total_paid / rental_count, 2)
    ELSE NULL
  END AS average_payment_per_rental
FROM customer_summary
ORDER BY total_paid DESC, customer_name;
