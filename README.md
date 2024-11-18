# AMAZON_SALES_ANALYSIS_SQL
![](https://www.supplychain247.com/images/article/amazon_india_wide_image.jpg)
Welcome to the Amazon Sales Analysis project! In this project, we delve into analyzing sales data from Amazon to extract insights and trends that can help optimize sales strategies, understand customer behavior, and improve business operations.
# Introduction
This project focuses on analyzing a dataset containing Amazon sales records, including information such as sales dates, customer details, product categories, and revenue figures. By leveraging SQL queries and data analysis techniques, we aim to answer various questions and uncover valuable insights from the dataset.

# Dataset Overview
The dataset used in this project consists of [insert number] rows of data, representing Amazon sales transactions. Along with the sales data, the dataset includes information about customers, products, orders, and returns. Before analysis, the dataset underwent preprocessing to handle missing values and ensure data quality.

# Analysis Questions Resolved
**During the analysis, the following key questions were addressed using SQL queries and data analysis techniques:**
1. Find out the top 5 customers who made the highest profits.
```sql
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
```
2. Find out the average quantity ordered per category.
```sql
SELECT 
      category,
	  AVG( quantity) as AVERAGE_QUANTITY
	  FROM orders
	  WHERE category is not null
	  GROUP BY 1
```
3. Identify the top 5 products that have generated the highest revenue.
```sql
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
```
4. Determine the top 5 products whose revenue has decreased compared to the previous year.
```sql
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
```
5. Identify the highest profitable sub-category.
```sql
SELECT 
      sub_category,
	  SUM(sale) - SUM(price_per_unit) AS HIGHEST_PROFITABLE_SUB_CATEGORY
	  FROM orders
	  WHERE sub_category is not null
	  GROUP BY 1
	  ORDER  BY 2 DESC
	  LIMIT 1;
```
6. Find out the states with the highest total orders.
```sql
SELECT state,
      COUNT(order_id) as Total_orders
FROM orders
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```
   
7. Determine the month with the highest number of orders.
```sql
SELECT
      EXTRACT(MONTH FROM order_date) as MONTH,
	  COUNT(order_id) as highest
	  FROM orders
	  GROUP BY 1
	  ORDER BY 2 DESC
	  LIMIT 1;
```

8. Calculate the profit margin percentage for each sale (Profit divided by Sales).
```sql
SELECT
    sale,
    SUM(price_per_unit/sale) AS profit_margin_percentage
FROM orders
GROUP BY 1
ORDER BY 2 DESC ;
```

9. Calculate the percentage contribution of each sub-category
```sql
SELECT 
    sub_category,
    SUM(sale) AS total_sales,
    ROUND(SUM(sale) * 100.0 / (SELECT SUM(sale) FROM orders) :: numeric(10,2)) AS percentage_contribution
FROM 
    orders
GROUP BY 
    sub_category;
```
10. Identify the top 2 categories that have received maximum returns and their return 
    percentage.
```sql
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
```


# Entity-Relationship Diagram (ERD)

![ERD_Amazon](https://github.com/prashanth2002/AMAZON_SALES_ANALYSIS_SQL/assets/54504321/09c57d09-bd1c-4e49-bb1c-6a1e0e95a008)
An Entity-Relationship Diagram (ERD) has been created to visualize the relationships between the tables in the dataset. This diagram provides a clear understanding of the data structure and helps in identifying key entities and their attributes.

# Getting Started
**To replicate the analysis or explore the dataset further, follow these steps:**

1. Clone the repository to your local machine.
2. Ensure you have a SQL environment set up to execute queries.
3. Load the provided dataset into your SQL database.
4. Execute the SQL queries provided in the repository to analyze the data and derive insights. 5. Customize the analysis or queries as needed for your specific objectives.

# Conclusion
Through this project, we aim to provide valuable insights into Amazon sales trends, customer preferences, and other factors influencing e-commerce operations. By analyzing the dataset and addressing the key questions, we hope to assist stakeholders in making informed decisions and optimizing their sales strategies. Feel free to explore the repository and contribute to further analysis or enhancements!
