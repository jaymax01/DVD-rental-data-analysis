/*
The database for this project can be access from the following link
https://www.postgresqltutorial.com/connect-to-postgresql-database/

*/ 


/* Query used for first insight */
SELECT film_title, category_name, COUNT(rental_no) AS rental_count
FROM
(SELECT l.title AS film_title, c.name AS category_name, r.rental_id AS rental_no
FROM category AS c
JOIN film_category AS f 
ON c.category_id = f.category_id
JOIN film AS l 
ON l.film_id = f.film_id
JOIN inventory AS i 
ON i.film_id = l.film_id
JOIN rental AS r 
ON r.inventory_id = i.inventory_id) sub
GROUP BY 1, 2
ORDER BY 2, 1

/* Query used for second insight */
SELECT l.title AS film_title, c.name AS category_name, 
l.rental_duration AS rental_duration, 
NTILE(4) OVER (ORDER BY l.rental_duration) AS standard_quantile
FROM category AS c
JOIN film_category AS f 
ON c.category_id = f.category_id
JOIN film AS l 
ON l.film_id = f.film_id
ORDER BY 2

/* Query used for third insight */
WITH table1 AS (SELECT c.customer_id AS customer_id, SUM(amount)
				FROM customer AS c
				JOIN payment AS p 
				ON p.customer_id = c.customer_id
				GROUP BY 1
				ORDER BY 2 DESC LIMIT 10
                )
                
SELECT Pay_month, fullname, Pay_countperperson, Pay_amount
FROM
(SELECT date_trunc('month', p.payment_date) AS Pay_month, c.customer_id AS cust_id,
c.first_name||' '||c.last_name AS fullname, COUNT(p.payment_id) AS Pay_countperperson, SUM(p.amount) AS Pay_amount
FROM payment AS p
JOIN customer AS c 
ON c.customer_id = p.customer_id
GROUP BY 1, 2, 3
HAVING c.customer_id in (SELECT customer_id FROM table1)
ORDER BY fullname) sub

/* Query used for fourth insight */
WITH table1 AS (SELECT c.customer_id AS customer_id, SUM(amount)
				FROM customer AS c
				JOIN payment AS p 
				ON p.customer_id = c.customer_id
				GROUP BY 1
				ORDER BY 2 DESC LIMIT 10
                )
                
SELECT Pay_month, fullname, Pay_countperperson, Pay_amount,
Pay_amount - lag(Pay_amount) OVER (PARTITION BY fullname ORDER BY Pay_month) AS Pay_difference
FROM
(SELECT date_trunc('month', p.payment_date) AS Pay_month, c.customer_id AS cust_id,
c.first_name||' '||c.last_name AS fullname, COUNT(p.payment_id) AS Pay_countperperson, SUM(p.amount) AS Pay_amount
FROM payment AS p
JOIN customer AS c 
ON c.customer_id = p.customer_id
GROUP BY 1, 2, 3
HAVING c.customer_id in (SELECT customer_id FROM table1)
ORDER BY fullname) sub
ORDER BY 2










