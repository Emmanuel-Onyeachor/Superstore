-- Analyzing data using MySql Sales Schema

USE sales;
SELECT * FROM sales.transactions;
SELECT * FROM sales.customers;
SELECT * FROM sales.date;
SELECT * FROM sales.markets;
SELECT * FROM sales.products;

-- Exploratory data analysis 1
SELECT * FROM transactions
where sales_amount < 0;

-- Remove transactions with negative sales amount
SET SQL_SAFE_UPDATES = 0;
DELETE FROM transactions
WHERE sales_amount < 0;
SET SQL_SAFE_UPDATES = 1;

-- Exploratory data analysis 2
SELECT * FROM transactions
where currency = "INR"
ORDER BY order_date;

SELECT * FROM transactions
where customer_code = "Cus001";

-- Remove transactions duplicated with wrong currency attached
SET SQL_SAFE_UPDATES = 0;
DELETE FROM transactions
WHERE currency = "INR";
SET SQL_SAFE_UPDATES = 1;

-- Exploratory data analysis 3
WITH Duplicates AS(
Select *, row_number() over(
	partition by customer_code, product_code, market_code, order_date, sales_qty, sales_amount
    order by customer_code) row_num
from transactions
)
Select * from Duplicates
where row_num > 1
Order by customer_code;

-- Remove duplicates
SET SQL_SAFE_UPDATES = 0;

WITH Duplicates AS(
Select *, row_number() over(
	partition by customer_code, product_code, market_code, order_date, sales_qty, sales_amount
    order by customer_code) row_num
from transactions
)
Delete from transactions
Using transactions JOIN Duplicates
ON transactions.customer_code = Duplicates.customer_code
where row_num > 1;

-- Calculate Revenue in Naira
Select *, (sales_qty * sales_amount)*5.26 as Rev
from transactions;

ALTER TABLE Transactions
ADD COLUMN Revenue INT AFTER Currency;

UPDATE Transactions
SET Revenue = (sales_qty * sales_amount)*5.26;

-- Correct error of value out of range for certain rows then re-run above query
ALTER TABLE Transactions
MODIFY Revenue BIGINT;

-- Change currency Value from INR to NGR
UPDATE Transactions
SET currency = 'NGR'
WHERE currency <> 'INR';

Select * from Transactions
where currency = 'ngr';

-- correct customer name header in customers table
select * from customers;

Alter table customers
RENAME COLUMN custmer_name to customer_name;

-- create view for visualization
Create View Master_table as
SELECT t.*, c.customer_name, c.customer_type,
m.markets_name, m.zone, p.product_type
FROM transactions t
JOIN customers c
ON t.customer_code = c.customer_code
JOIN markets m
ON t.market_code = m.markets_code
JOIN products p
ON t.product_code = p.product_code;

Select * from Master_table;

-- Connect to power bi for visualization

