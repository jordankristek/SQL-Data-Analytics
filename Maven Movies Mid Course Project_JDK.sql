USE mavenmovies;

/* Question 1: We will need a list of all staff members, including first and last name, email address, 
and the store id number where they work*/

SELECT
	first_name,
    last_name,
    email,
    store_id
FROM staff;

/* Question 2: We will need separate counts of inventory items held at each of your two stores
*/

SELECT
	store_id,
    COUNT(inventory_id) AS total_inventory
FROM inventory
GROUP BY store_id;

/* Question 3: We will need a count of active customers for each of your stores. Separately, please.
*/

SELECT
	store_id,
    COUNT(CASE WHEN active = 1 THEN customer_id ELSE NULL END) AS active_customers
FROM customer
GROUP BY store_id;

/* Question 4: In order the assess the liability of a data breach, we will need you to provide a count of 
all customer email addresses stored in the database.
*/

SELECT
	SUM(CASE WHEN email IS NOT NULL THEN 1 ELSE 0 END) AS emails_on_file
FROM customer;

/* Question 5: We are interested in how diverse your film offering is as a means of understanding how 
likely you areto keep customers engaged in the future. Please provide a count of unique film titles you 
have in inventoryat each store and then provide a count of the unique categories of films you provide. 
*/

SELECT
	inventory.store_id,
	COUNT(DISTINCT inventory.film_id) as distinct_films,
    COUNT(DISTINCT film_category.category_id) AS distinct_categories
FROM inventory
LEFT JOIN film_category
	ON inventory.film_id = film_category.film_id
GROUP BY store_id;

/* Question 6: We would like to understand the replacement cost of your films. Please provide the 
replacement costfor the film that is least expensive to replace, the most expensive to replace, and the 
average of all films you carry. 
*/

SELECT
	MIN(replacement_cost) AS lowest_replacement_cost,
    MAX(replacement_cost) AS highest_replacement_cost,
    AVG(replacement_cost) AS average_replacement_cost
FROM film;

/* Question 7: We are interested in having you put payment monitoring systems and maximum payment 
processing restrictions in place in order to minimize the future risk of fraud by your staff. Please 
provide the average payment you process, as well as the maximum payment you have processed. 
*/

SELECT
	AVG(amount) AS avg_payment,
    MAX(amount) AS max_payment
FROM payment;

/* Question 8: We would like to better understand what your customer base looks like. Please provide a 
list of all customer identification values, with a count of rentals they have made all-time, with your 
highest volume cusomers at the top of the list. 
*/

SELECT
	customer_id,
    COUNT(DISTINCT rental_id) AS rentals
FROM rental
GROUP BY customer_id
ORDER BY COUNT(DISTINCT rental_id) desc;