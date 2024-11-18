-- first import into products,
-- import into customers
-- import into sellers
-- import into orders
-- import into returns
-- creating customers table 
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
						 	customer_id VARCHAR(25) PRIMARY KEY,
						    customer_name VARCHAR(25),
						    state VARCHAR(25)
);
-- creating sellers table 
DROP TABLE IF EXISTS sellers;
CREATE TABLE sellers (
					    seller_id VARCHAR(25) PRIMARY KEY,
					    seller_name VARCHAR(25)
);
-- creating products table 
DROP TABLE IF EXISTS products;
CREATE TABLE products (
					    product_id VARCHAR(25) PRIMARY KEY,
					    product_name VARCHAR(255),
					    Price FLOAT,
					    cogs FLOAT
);
-- creating orders table 
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
					    order_id VARCHAR(25) PRIMARY KEY,
					    order_date DATE,
					    customer_id VARCHAR(25),  -- this is a foreign key from customers(customer_id)
					    state VARCHAR(25),
					    category VARCHAR(25),
					    sub_category VARCHAR(25),
					    product_id VARCHAR(25),   -- this is a foreign key from products(product_id)
					    price_per_unit FLOAT,
					    quantity INT,
					    sale FLOAT,
						seller_id VARCHAR(25),    -- this is a foreign key from sellers(seller_id)
	
					    CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
					    CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),    
					    CONSTRAINT fk_sellers FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);
-- creating returns table 
DROP TABLE IF EXISTS returns;
CREATE TABLE returns (
					    order_id VARCHAR(25),
					    return_id VARCHAR(25),
					    CONSTRAINT pk_returns PRIMARY KEY (order_id), -- Primary key constraint
					    CONSTRAINT fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
-- ----------------------------------------------------------------------------------------------------------------------
--  Q1 Find out the top 5 customers who made the highest profits.
SELECT
       o.customer_id,
	   c.customer_name,
	  ROUND(SUM (o.sale)::NUMERIC ,2)as HIGHTEST_PROFITS
	  FROM orders as o
	  INNER JOIN
	  customers as c
	  ON o.customer_id = c.customer_id
	  GROUP BY 1,2
	  ORDER BY 3 DESC
	  LIMIT 5;
	  
-- ------------------------------------------------------------------------------------------------------------
-- Q2 Find out the average quantity ordered per category.
SELECT 
      category,
	  AVG( quantity) as AVERAGE_QUANTITY
	  FROM orders
	  WHERE category is not null
	  GROUP BY 1
	  
-- ----------------------------------------------------------------------------
-- Q3 Identify the top 5 products that have generated the highest revenue
	  
SELECT 
     o. product_id,
	 p. product_name,
	 ROUND(SUM(o.sale)::NUMERIC,2) Highest_revenue
	  FROM products as p
	  INNER JOIN 
	  orders as o
	  ON o.product_id = p.product_id
	  GROUP BY 1,2
	  ORDER BY 3 DESC
	  LIMIT 5;
-- -----------------------------------------------------------------------------------
-- Q4 Determine the top 5 products whose revenue has decreased compared to the previous year.
WITH py1 AS
(
    SELECT
        p.product_name,
        SUM(o.sale) AS revenue
    FROM 
        orders AS o
    JOIN 
        products AS p ON o.product_id = p.product_id
    WHERE 
        o.order_date >= '2023-01-01' AND o.order_date <= '2023-12-31'
    GROUP BY 
        p.product_name
),
py2 AS 
(
    SELECT
        p.product_name,
        SUM(o.sale) AS revenue
    FROM 
        orders AS o
    JOIN 
        products AS p ON o.product_id = p.product_id
    WHERE 
        o.order_date >= '2022-01-01' AND o.order_date <= '2022-12-31'
    GROUP BY 
        p.product_name
)
SELECT
    py1.product_name,
    py1.revenue AS current_revenue,
    py2.revenue AS prev_revenue,
    (py1.revenue / py2.revenue) AS revenue_decreased_ratio
FROM 
    py1
JOIN 
    py2 ON py1.product_name = py2.product_name
WHERE 
    py1.revenue < py2.revenue
ORDER BY 
    py1.revenue DESC
LIMIT 5;
-- ----------------------------------------------------------------------------------------------------------------
-- Q5-Identify the highest profitable sub-category.
SELECT category,
       SUM(sale - (price_per_unit * quantity)) AS total_profit 
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
-- ----------------------------------------------------------------------------------------------------------------
-- Q6-Find out the states with the highest total orders.
SELECT state,
      COUNT(order_id) as Total_orders
FROM orders
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
-- -----------------------------------------------------------------------------------------------------------------------
-- Q5 Identify the highest profitable sub-category.
SELECT 
      sub_category,
	  SUM(sale) - SUM(price_per_unit) AS HIGHEST_PROFITABLE_SUB_CATEGORY
	  FROM orders
	  WHERE sub_category is not null
	  GROUP BY 1
	  ORDER  BY 2 DESC
	  LIMIT 1;
	  
	  
	  
-- --------------------------------------------------------------------------------------------------------
-- Q6 Find out the states with the highest total orders.
SELECT 
      state,
	  COUNT(order_id) AS higest_total_orders
	  FROM orders
	  GROUP BY 1
	  ORDER BY 2 DESC
	  
-- ------------------------------------------------------------------------------------------------------------
-- Q7 Determine the month with the highest number of orders.
	  
SELECT
      EXTRACT(MONTH FROM order_date) as MONTH,
	  COUNT(order_id) as highest
	  FROM orders
	  GROUP BY 1
	  ORDER BY 2 DESC
	  LIMIT 1;
	  
-- ------------------------------------------------------------------------------
-- Q8 Calculate the profit margin percentage for each sale (Profit divided by Sales).
SELECT
    sale,
    SUM(price_per_unit/sale) AS profit_margin_percentage
FROM orders
GROUP BY 1
ORDER BY 2 DESC ;
--  -------------------------------------------------
-- 	Q9 Calculate the percentage contribution of each sub-category
SELECT 
    sub_category,
    SUM(sale) AS total_sales,
    ROUND(SUM(sale) * 100.0 / (SELECT SUM(sale) FROM orders) :: numeric(10,2)) AS percentage_contribution
FROM 
    orders
GROUP BY 
    sub_category;
	
-- -------------------------------------------
-- Q10 .Identify top 2 category that has received maximum returns and their return %
		  
SELECT 
    O.category,
    COUNT(R.order_id) AS total_returns,
    (COUNT(R.order_id) * 100.0 / (SELECT COUNT(*) FROM returns)) AS return_percentage
FROM 
    orders AS O
JOIN 
    returns AS R ON O.order_id = R.order_id
GROUP BY 
    O.category
ORDER BY 
    total_returns DESC
LIMIT 2;