-- Create new database
CREATE DATABASE fetch_project;

-- Use this database
USE fetch_project;

-- Create Products table
CREATE TABLE Products (
    category_1 VARCHAR(30),
    category_2 VARCHAR(30),
    category_3 VARCHAR(40),
    category_4 VARCHAR(40),
    manufacturer VARCHAR(40),
    brand VARCHAR(40),
    barcode VARCHAR(50) PRIMARY KEY
);

-- Create Users table
CREATE TABLE Users (
    id VARCHAR(50) PRIMARY KEY,
    created_date DATETIME,
    birth_date DATE,
    state VARCHAR(50),
    language VARCHAR(50),
    gender VARCHAR(20)
);

-- Create Transactions table
CREATE TABLE Transactions (
    receipt_id VARCHAR(50) PRIMARY KEY,
    purchase_date DATETIME,
    scan_date DATE,
    store_name VARCHAR(100),
    user_id VARCHAR(50),
    barcode VARCHAR(50),
    quantity INT,
    sale DECIMAL(10, 2)
);

-- Q1: Find top 5 brands by receipts scanned among users 21 and over
SELECT p.brand, COUNT(t.receipt_id) AS receipt_count
FROM Transactions t
JOIN Users u ON t.user_id = u.id
JOIN Products p ON t.barcode = p.barcode
WHERE TIMESTAMPDIFF(YEAR, u.birth_date, CURDATE()) >= 21
GROUP BY p.brand
ORDER BY receipt_count DESC
LIMIT 5;

-- Q2: Find top 5 brands by sales among users that have had their account for at least 6 months
SELECT p.brand, SUM(t.sale) AS total_sales
FROM Transactions t
JOIN Users u ON t.user_id = u.id
JOIN Products p ON t.barcode = p.barcode
WHERE u.created_date < DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY p.brand
ORDER BY total_sales DESC
LIMIT 5;

-- Q3: Percentage of sales in the Health & Wellness category by generation
SELECT
  CASE
    WHEN TIMESTAMPDIFF(YEAR, u.birth_date, CURDATE()) < 25 THEN 'Gen Z'
    WHEN TIMESTAMPDIFF(YEAR, u.birth_date, CURDATE()) BETWEEN 25 AND 40 THEN 'Millennials'
    WHEN TIMESTAMPDIFF(YEAR, u.birth_date, CURDATE()) BETWEEN 41 AND 56 THEN 'Gen X'
    ELSE 'Boomers'
  END AS generation,
  SUM(t.sale) AS total_sales,
  (SUM(t.sale) / (SELECT SUM(t2.sale) FROM Transactions t2)) * 100 AS sales_percentage
FROM Transactions t
JOIN Users u ON t.user_id = u.id
JOIN Products p ON t.barcode = p.barcode
WHERE p.category_1 = 'Health & Wellness'
GROUP BY generation;

-- Q4: Leading brand in the Dips & Salsa category (excluding 'Unknown' brand)
SELECT p.brand, SUM(t.sale) AS total_sales
FROM Transactions t
JOIN Products p ON t.barcode = p.barcode
WHERE (p.category_1 LIKE '%Dips%' OR p.category_2 LIKE '%Dips%' OR p.category_3 LIKE '%Dips%' OR p.category_4 LIKE '%Dips%'
   OR p.category_1 LIKE '%Salsa%' OR p.category_2 LIKE '%Salsa%' OR p.category_3 LIKE '%Salsa%' OR p.category_4 LIKE '%Salsa%')
   AND p.brand != 'Unknown'
GROUP BY p.brand
ORDER BY total_sales DESC
LIMIT 1;

-- Q5: Fetch year-over-year growth percentage
WITH sales_data AS (
  SELECT 
    QUARTER(t.purchase_date) AS quarter,
    SUM(t.sale) AS total_sales
  FROM Transactions t
  GROUP BY quarter
)
SELECT 
  (MAX(total_sales) - MIN(total_sales)) * 100 / MIN(total_sales) AS growth_percentage
FROM sales_data;
