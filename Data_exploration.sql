-- Data Exploration
select count(*) from "Walmart"; -- 9969

-- How many distinct payment methods are there
select Distinct payment_method from "Walmart"; -- 3

-- Which payment methods are used the most
select 
   payment_method,
   count(*)
from "Walmart"
group by payment_method; -- credit cart is most frequently used


-- How many distinct number of branches are there
select count(Distinct branch)
from "Walmart";   -- 100 



-- Business Problems
--Q.1 Find different payment method and number of transactions, number of qty sold


SELECT 
	 payment_method,
	 COUNT(*) as no_payments,
	 SUM(quantity) as no_qty_sold
FROM "Walmart"
GROUP BY payment_method;


-- Q.2
-- Identify the highest-rated category in each branch, displaying the branch, category
-- AVG RATING

SELECT * 
FROM
(	SELECT 
		branch,
		category,
		AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
	FROM "Walmart"
	GROUP BY 1, 2
)
WHERE rank = 1;

-- Q.3 Identify the busiest day for each branch based on the number of transactions

SELECT * 
FROM
	(SELECT 
		branch,
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') as day_name,
		COUNT(*) as no_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	FROM "Walmart"
	GROUP BY 1, 2
	)
WHERE rank = 1;


-- Q.4
-- Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.

SELECT 
	city,
	category,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating,
	AVG(rating) as avg_rating
FROM "Walmart"
GROUP BY 1, 2;



-- Q.5
-- Calculate the total profit and total revenue for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.

SELECT 
	category,
	SUM(total) as total_revenue,
	SUM(total * profit_margin) as profit
FROM "Walmart"
GROUP BY 1;


-- Q.6
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.

SELECT *
FROM
	(SELECT 
		branch,
		payment_method,
		COUNT(*) as total_trans,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	FROM "Walmart"
	GROUP BY 1, 2
	)
WHERE rank = 1;



-- Q.7
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

SELECT
	branch,
CASE 
		WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*)
FROM "Walmart"
GROUP BY 1, 2
ORDER BY 1, 3 DESC;



-- Q.8
-- Find out total revenue per year for each branch

-- i encountered an error here
SELECT 
    branch,
    EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) AS year,
    SUM(total) AS total_revenue
FROM 
    "Walmart"
GROUP BY 
    branch, EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY'))
ORDER BY 
    1, 2;


-- Q.9
-- Find out total revenue per year for every category in  each branch
SELECT 
    branch,
    category,
    EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) AS year,
    SUM(total) AS category_revenue
FROM 
    "Walmart"
GROUP BY 
    branch, category, EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY'))
ORDER BY 
    1, 2, 3;


-- #10 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)

-- rdr == last_rev-cr_rev/ls_rev*100

SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart

-- 2022 sales
WITH revenue_2022
AS
(
	SELECT 
		branch,
		SUM(total) as revenue
	FROM "Walmart"
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 -- psql
	-- WHERE YEAR(TO_DATE(date, 'DD/MM/YY')) = 2022 -- mysql
	GROUP BY 1
),

revenue_2023
AS
(

	SELECT 
		branch,
		SUM(total) as revenue
	FROM "Walmart"
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100,  -- in my sql there is typecasting
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5;



-- #11 Identify 5 branch with highest increase ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)

-- rdr == last_rev-cr_rev/ls_rev*100

SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart

-- 2022 sales
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM "Walmart"
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
    GROUP BY branch
),

revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM "Walmart"
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
    GROUP BY branch
)

SELECT 
    ls.branch,
    ls.revenue AS last_year_revenue,
    cs.revenue AS current_year_revenue,
    ROUND(
        (cs.revenue - ls.revenue)::NUMERIC / ls.revenue::NUMERIC * 100,
        2
    ) AS revenue_increase_ratio
FROM revenue_2022 ls
JOIN revenue_2023 cs ON ls.branch = cs.branch
WHERE cs.revenue > ls.revenue
ORDER BY revenue_increase_ratio DESC
LIMIT 5;








