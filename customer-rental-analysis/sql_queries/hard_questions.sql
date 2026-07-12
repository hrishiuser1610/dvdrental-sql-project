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




----Q4.Customer Segmentation Using CASE

SELECT 
      customer.customer_id,
	  CONCAT(first_name, ' ', last_name) AS customer_name,
	  SUM(payment.amount)AS total_spending,
	  CASE
	      WHEN SUM(payment.amount)> 180 THEN 'VIP'
	      WHEN SUM(payment.amount)BETWEEN 151 AND 180 THEN 'High Value'
		  WHEN SUM (payment.amount) BETWEEN 100 AND 150 THEN 'Medium Value'
		  ELSE 'Low Value'
	  END AS customer_segment
FROM customer
JOIN payment 
    ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id,
         first_name,
		 last_name
ORDER BY total_spending DESC


----Q5. Find Customers Who Spend Above the Average Customer Spending

WITH spending AS(
    SELECT 
	      customer.customer_id AS customer_id,
		  CONCAT(first_name, ' ', last_name)AS customer_name,
		  SUM (payment.amount) AS total_spending
FROM customer
JOIN payment 
    ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id,
         first_name,
		 last_name
)

SELECT 
      customer_id,
	  customer_name,
	  total_spending
FROM spending
WHERE total_spending > ( SELECT 
                                AVG(total_spending)
						   FROM spending
)
ORDER BY total_spending DESC;


-----Q6.Top 5 Highest Revenue-Generating Film Categories


SELECT 
      category.name AS category_name,
	  SUM(payment.amount) total_revenue
FROM category
JOIN film_category 
    ON category.category_id = film_category.category_id
JOIN film
    ON film_category.film_id = film.film_id
JOIN inventory
    ON film.film_id = inventory.film_id
JOIN rental
    ON inventory.inventory_id = rental.inventory_id
JOIN payment
    ON rental.rental_id = payment.rental_id
GROUP BY category.name
ORDER BY total_revenue DESC
LIMIT 5;




---Q7. Month-over-Month (MoM) Revenue Growth


WITH monthly_revenue AS(
SELECT
      EXTRACT(YEAR FROM payment_date) AS year,
	  EXTRACT(MONTH FROM payment_date) AS month,
	  SUM(amount) AS monthly_revenue
FROM payment
GROUP BY EXTRACT(YEAR FROM payment_date),
         EXTRACT(MONTH FROM payment_date)
)

SELECT
      year,
	  month,
	  monthly_revenue,
	  ROUND (LAG (monthly_revenue, 1) OVER (ORDER BY year, month), 2) AS prev_revenue,
	  ROUND(((monthly_revenue-LAG (monthly_revenue, 1) OVER (ORDER BY year,month))/
	  LAG (monthly_revenue, 1) OVER (ORDER BY year, month))*100, 2) AS revenue_growth
FROM monthly_revenue	 




----Q8.Top 3 Customers in Each Country by Total Spending


WITH total_spending AS(
    SELECT 
	      country.country,
		  customer.customer_id,
		  CONCAT(first_name, ' ', last_name) AS customer_name,
		  SUM(payment.amount) AS total_spend,
		  DENSE_RANK() OVER (PARTITION BY country.country ORDER BY SUM(payment.amount) DESC) AS customer_rank
	FROM payment
	JOIN customer
	    ON payment.customer_id = customer.customer_id
	JOIN address
	    ON customer.address_id = address.address_id
	JOIN city
	    ON address.city_id = city.city_id
	JOIN country
	    ON city.country_id = country.country_id
GROUP BY country.country,
		  customer.customer_id,
		  first_name,
		  last_name
)

SELECT  
      country,
	  customer_id,
	  customer_name,
	  total_spend,
	  customer_rank
FROM total_spending
WHERE customer_rank <= 3;



---Q9.Find Customers Who Haven't Rented in the Last 90 Days


SELECT 
      customer.customer_id,
	  CONCAT(first_name, ' ', last_name) AS customer_name,
	  MAX(rental_date) AS last_rental_date
FROM customer
LEFT JOIN rental
         ON customer.customer_id = rental.customer_id
GROUP BY customer.customer_id,
         first_name,
		 last_name
HAVING MAX(rental_date) < ( CURRENT_DATE - INTERVAL '90 days' )






---Q10.Calculate Customer Lifetime Value (CLV)


SELECT 
      customer.customer_id,
	  CONCAT(first_name,' ', last_name) AS customer_name,
	  COUNT(payment.rental_id) AS total_rental,
	  SUM(payment.amount)AS total_revenue,
	  ROUND(AVG(payment.amount), 2)AS average_payment,
	  DENSE_RANK() OVER (ORDER BY SUM(payment.amount) DESC ) AS customer_rank
FROM customer
JOIN payment
    ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id,
         first_name,
		 last_name;
		 

	

	  
	  










