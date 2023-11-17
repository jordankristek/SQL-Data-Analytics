USE mavenfuzzyfactory;

/* Question 1: Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for
gsearch sessions and orders so that we can showcase the growth there?
*/

SELECT
	MONTH(website_sessions.created_at) AS month,
    YEAR(website_sessions.created_at) AS year,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
WHERE
	website_sessions.utm_source = 'gsearch'
    AND website_sessions.created_at < '2012-11-27'
GROUP BY 
month,
year;

/* Question 2: Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting
out nonbrand and brand campaigns separately. I am wondering if brand is picking up at all. If so, this
is a pretty good story to tell.
*/

SELECT
	MONTH(website_sessions.created_at) AS month,
    YEAR(website_sessions.created_at) AS year,
    website_sessions.utm_campaign,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
WHERE
	website_sessions.utm_source = 'gsearch'
    AND website_sessions.created_at < '2012-11-27'
GROUP BY 
month,
year,
website_sessions.utm_campaign;

-- Pivoted another way...
SELECT
	MONTH(website_sessions.created_at) AS month,
    YEAR(website_sessions.created_at) AS year,
    COUNT(CASE WHEN website_sessions.utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_sessions,
    COUNT(CASE WHEN website_sessions.utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS nonbrand_sessions,
    COUNT(CASE WHEN website_sessions.utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_orders,
    COUNT(CASE WHEN website_sessions.utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS nonbrand_orders
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
WHERE
	website_sessions.utm_source = 'gsearch'
    AND website_sessions.created_at < '2012-11-27'
GROUP BY 
month,
year;

/* Question 3: While we're on Gsearch, could you dive into nonbrand, and pull monthly sessions	and orders
split by device type? I want to flex our analytical muscles a little and show the board we really know
our traffic sources.
*/

SELECT
	MONTH(website_sessions.created_at) AS month,
    YEAR(website_sessions.created_at) AS year,
    website_sessions.device_type,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
WHERE
	website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
    AND website_sessions.created_at < '2012-11-27'
GROUP BY 
month,
year,
website_sessions.device_type;

-- Pivoted with the CASE method
SELECT
	MONTH(website_sessions.created_at) AS month,
    YEAR(website_sessions.created_at) AS year,
    COUNT(CASE WHEN website_sessions.device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(CASE WHEN website_sessions.device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(CASE WHEN website_sessions.device_type = 'desktop' THEN orders.order_id ELSE NULL END) AS desktop_orders,
    COUNT(CASE WHEN website_sessions.device_type = 'mobile' THEN orders.order_id ELSE NULL END) AS mobile_orders
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
WHERE
	website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
    AND website_sessions.created_at < '2012-11-27'
GROUP BY 
month,
year;

/* Question 4: I'm worried that one of our more pessimistic board members may be concerned about the
large % of traffic from Gsearch. Can you pull monthly trends for Gsearch, alongside monthly trends for
each of our other channels?
*/

SELECT
	MONTH(website_sessions.created_at) AS month,
    YEAR(website_sessions.created_at) AS year,
    website_sessions.utm_source,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at < '2012-11-27'
GROUP BY 
month,
year,
website_sessions.utm_source;

/* Question 5: I'd like to tell the story of our website performance improvements over the course of the
first 8 months. Could you pull session to order conversion rates, by month?
*/

SELECT
	MONTH(website_sessions.created_at) AS month,
    YEAR(website_sessions.created_at) AS year,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
WHERE
	website_sessions.created_at < '2012-11-27'
GROUP BY
	month,
    year;
    
/* Question 6: For the gsearch lander test, please estimate the revenue that test earned us (Hint: Look at
the increase in CVR from the test (Jun 19 - Jul 28), and use nonbrand sessions and revenue since then to
calculate incremental value.
*/

-- First, we find the minimum pageview_id for /lander-1
SELECT
	MIN(website_pageview_id) AS first_lander1_pageview
FROM website_pageviews
WHERE
	pageview_url = '/lander-1';

-- The first /lander-1 pageview_id was 23504

-- Next, identify the first pageview_id for each gsearch nonbrand session
CREATE TEMPORARY TABLE min_test_pageviews
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
INNER JOIN website_sessions
	ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE
	website_sessions.created_at < '2012-07-28'
    AND website_pageviews.website_pageview_id >= 23504
    AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY
	website_pageviews.website_session_id;
    
-- Assign the landing page to each session with a home or lander-1 url
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_page
SELECT
	min_test_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM min_test_pageviews
LEFT JOIN website_pageviews
	ON min_test_pageviews.min_pageview_id = website_pageviews.website_pageview_id
WHERE
	website_pageviews.pageview_url IN ('/home', '/lander-1');
    
-- Merge orders with these sessions
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_orders
SELECT
	nonbrand_test_sessions_w_landing_page.website_session_id,
    nonbrand_test_sessions_w_landing_page.landing_page,
    orders.order_id
FROM nonbrand_test_sessions_w_landing_page
LEFT JOIN orders
	ON nonbrand_test_sessions_w_landing_page.website_session_id = orders.website_session_id;
    
-- Calculate the difference between conversion rates
SELECT
	landing_page,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) AS conv_rate
FROM nonbrand_test_sessions_w_orders
GROUP BY landing_page;

-- /home conv_rate = 0.0319
-- /lander-1 conv_rate = 0.0406
-- /lander-1 results in an additional 0.0087 orders per session

-- Now find the most recent pageview for gsearch nonbrand /home page
SELECT 
	MAX(website_sessions.website_session_id) AS most_recent_gsearch_nonbrand_home_pageview 
FROM website_sessions 
LEFT JOIN website_pageviews 
	ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
    AND pageview_url = '/home'
    AND website_sessions.created_at < '2012-11-27';

-- Most recent gsearch nonbrand home pageview is 17145

SELECT 
	COUNT(website_session_id) AS sessions_since_test
FROM website_sessions
WHERE created_at < '2012-11-27'
	AND website_session_id > 17145
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand';
    
-- 22972 sessions since test * .0087 incremental conversion = 202 incremental orders since 7/29

/*
Question 7:	For the landing page test you analyzed previously, it would be great to show a full 
conversion funnel from each of the two pages to orders. You can use the same time period you analyzed 
last time (Jun 19 – Jul 28).
*/ 

-- Assign a 0/1 value to each website pageview url
SELECT
	website_sessions.website_session_id, 
    website_pageviews.pageview_url,
    CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
    CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS custom_lander,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page, 
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions 
	LEFT JOIN website_pageviews 
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch' 
	AND website_sessions.utm_campaign = 'nonbrand' 
    AND website_sessions.created_at < '2012-07-28'
		AND website_sessions.created_at > '2012-06-19'
ORDER BY 
	website_sessions.website_session_id,
    website_pageviews.created_at;

-- Use the code above to create a temporary table to demonstrate which lander each session started on 
-- and whether or not they made it to each subsequent page
CREATE TEMPORARY TABLE session_level_made_it_flagged
SELECT
	website_session_id, 
    MAX(homepage) AS saw_homepage, 
    MAX(custom_lander) AS saw_custom_lander,
    MAX(products_page) AS product_made_it, 
    MAX(mrfuzzy_page) AS mrfuzzy_made_it, 
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM(
SELECT
	website_sessions.website_session_id, 
    website_pageviews.pageview_url,
    CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
    CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS custom_lander,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page, 
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions 
	LEFT JOIN website_pageviews 
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch' 
	AND website_sessions.utm_campaign = 'nonbrand' 
    AND website_sessions.created_at < '2012-07-28'
		AND website_sessions.created_at > '2012-06-19'
ORDER BY 
	website_sessions.website_session_id,
    website_pageviews.created_at
) AS pageview_level

GROUP BY 
	website_session_id;

-- Count how many sessions saw each lander page and how many of those sessions made it to each subsequent page
SELECT
	CASE 
		WHEN saw_homepage = 1 THEN 'saw_homepage'
        WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
        ELSE 'check logic' 
	END AS segment, 
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM session_level_made_it_flagged 
GROUP BY 1;

-- Use the same logic as above to calculate click through rates starting on each lander page
SELECT
	CASE 
		WHEN saw_homepage = 1 THEN 'saw_homepage'
        WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
        ELSE 'check logic' 
	END AS segment, 
	COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS lander_click_rt,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS products_click_rt,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rt,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_click_rt,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rt,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_click_rt
FROM session_level_made_it_flagged
GROUP BY 1;

/*
8.	I’d love for you to quantify the impact of our billing test, as well. Please analyze the lift generated 
from the test (Sep 10 – Nov 10), in terms of revenue per billing page session, and then pull the number 
of billing page sessions for the past month to understand monthly impact.
*/ 

-- Identify all of the sessions that made it to a billing page and quantify how much revenue was generated
-- per billing page
SELECT
	billing_version_seen, 
    COUNT(DISTINCT website_session_id) AS sessions, 
    SUM(price_usd)/COUNT(DISTINCT website_session_id) AS revenue_per_billing_page_seen
 FROM( 
SELECT 
	website_pageviews.website_session_id, 
    website_pageviews.pageview_url AS billing_version_seen, 
    orders.order_id, 
    orders.price_usd
FROM website_pageviews 
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at > '2012-09-10' -- prescribed in assignment
	AND website_pageviews.created_at < '2012-11-10' -- prescribed in assignment
    AND website_pageviews.pageview_url IN ('/billing','/billing-2')
) AS billing_pageviews_and_order_data
GROUP BY 1;

-- $22.83 revenue per billing page seen for the old version
-- $31.34 for the new version
-- Additional revenue generated by new billing screen: $8.51 per billing session

-- Count how many sessions made it to a billing page in the past month
SELECT 
	COUNT(website_session_id) AS billing_sessions_past_month
FROM website_pageviews 
WHERE website_pageviews.pageview_url IN ('/billing','/billing-2') 
	AND created_at BETWEEN '2012-10-27' AND '2012-11-27';

-- 1,194 billing sessions past month
-- LIFT: $8.51 per billing session
-- VALUE OF BILLING TEST: $10,160 over the past month





