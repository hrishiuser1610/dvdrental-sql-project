----Q 1.Running Total Revenue by Month

WITH total_revenue AS(
     SELECT 
	      EXTRACT(YEAR FROM payment_date) AS year,
	      EXTRACT(MONTH FROM payment_date) AS month,
		  SUM (amount) AS monthly_revenue
		  FROM payment
GROUP BY EXTRACT(YEAR FROM payment_date),
	     EXTRACT(MONTH FROM payment_date)
)

SELECT 
      year,
	  month,
	  monthly_revenue,
	  SUM(monthly_revenue) OVER (ORDER BY year, month) as running_total
from total_revenue;
      


----Q2. Rank customers based on total spending.


WITH spending AS (
    SELECT 
	      customer.customer_id AS customer_id,
		  CONCAT(customer.first_name, ' ',customer.last_name) AS customer_name,
		  SUM(payment.amount) as total_spending
		  FROM customer
JOIN payment
    ON customer.customer_id = payment.customer_id
GROUP BY  customer.customer_id,
		  CONCAT(customer.first_name, ' ',customer.last_name)
)


SELECT  
      RANK() OVER (ORDER BY total_spending DESC ),
      customer_id,
	  customer_name,
	  total_spending
FROM spending;




----Q3. Find the most rented movie in each category.


WITH rented_movie AS(
    SELECT 
	      category.name AS category,
	      film.title AS movie_title,
		  COUNT(rental_id) AS total_rental
	 FROM category
	 JOIN film_category
	     ON category.category_id = film_category.category_id
	 JOIN film
	     ON film_category.film_id = film.film_id
	 JOIN inventory
	     ON film.film_id = inventory.film_id
	 JOIN rental
	     ON inventory.inventory_id = rental.inventory_id
	 GROUP BY category.name,
	          film.title
		  
),

 movie_rank AS(
    SELECT
      category,
      movie_title,
      total_rental,
      ROW_NUMBER() OVER( PARTITION BY category ORDER BY total_rental DESC) AS rented
FROM rented_movie
)

SELECT 
     category,
	 movie_title,
	 total_rental
FROM movie_rank
WHERE rented = 1;
