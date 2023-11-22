-- Objective 1

-- View the menu_itmems table and write a query to find the number of items on the menu
USE restaurant_db;
SELECT COUNT(DISTINCT menu_item_id) AS menu_items
FROM menu_items;

-- What are the least and most expensive items on the menu?
SELECT
	item_name,
	price
FROM menu_items
ORDER BY price ASC;

SELECT
	item_name,
	price
FROM menu_items
ORDER BY price DESC;

-- How many Italian dishes are on the menu? What are the least and most expensive Italian dishes on the menu?
SELECT
	COUNT(CASE WHEN category = 'Italian' THEN menu_item_id ELSE null END) AS italian_dishes
FROM menu_items;

SELECT * FROM menu_items
WHERE category = 'Italian'
ORDER BY price DESC;

-- How many dishes are in each category? What is the average dish price within each category?
SELECT
	category,
    COUNT(menu_item_id) AS items,
    AVG(price) AS avg_price
FROM menu_items
GROUP BY category;

-- Objective 2

-- View the order_details table. What is the date range of the table?
SELECT * FROM order_details
ORDER BY order_date ASC;

SELECT * FROM order_details
ORDER BY order_date DESC;

-- How many orders were made within this date range? How many items were ordered within this date range?
SELECT
	COUNT(DISTINCT order_id) AS orders,
    COUNT(item_id) AS items
FROM order_details;

-- Which orders had the most number of items?
SELECT
	order_id,
    COUNT(item_id) AS items
FROM order_details
GROUP BY order_id
ORDER BY COUNT(item_id) DESC;

-- How many orders had more than 12 items?
SELECT
	COUNT(order_id) AS orders_greater_than_12
FROM
(
SELECT
	order_id,
    COUNT(item_id) AS items
FROM order_details
GROUP BY order_id
HAVING COUNT(item_id) > 12
) AS grouped_12_plus;

-- Objective 3

-- Combine the 	menu_items and order_details tables into a single table
SELECT *
FROM order_details od
LEFT JOIN menu_items mi
	ON mi.menu_item_id = od.item_id;
    
-- What were the least and most ordered items? What categories were they in?
SELECT
	menu_items.item_name,
    menu_items.category,
	COUNT(DISTINCT order_details.order_details_id) AS times_ordered
FROM order_details
LEFT JOIN menu_items
	ON order_details.item_id = menu_items.menu_item_id
GROUP BY 
	menu_items.item_name,
    menu_items.category
ORDER BY times_ordered DESC;

-- What were the top 5 orders that spent the most money?
SELECT *
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id;
    
SELECT 
	od.order_id,
    SUM(mi.price) AS amount_spent
FROM order_details od
LEFT JOIN menu_items mi
	ON mi.menu_item_id = od.item_id
GROUP BY od.order_id
ORDER BY SUM(mi.price) DESC
LIMIT 5;

-- View the details of the highest spend order. Which specific items were purchased?
SELECT *
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id
WHERE od.order_id = 440;

-- View the details of the top 5 highest spend orders
SELECT *
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id
WHERE od.order_id IN (440, 2075, 1957, 330, 2675);