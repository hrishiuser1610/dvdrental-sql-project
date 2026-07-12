----Q1.Show all customers with:
---customer_id
---first_name
---last_name
---email

SELECT 
      customer_id, 
	  first_name, 
	  last_name, 
	  email 
FROM customer;

----Q2.Find all movies released with rental rate greater than 3.

SELECT 
      title
FROM film
WHERE rental_rate > 3;

----Q3.Count total number of customers.

SELECT 
      COUNT(customer_id) 
FROM customer;


----Q4.Show top 10 longest movies.

SELECT
      title,
	  length 
FROM film
ORDER BY length DESC
LIMIT 10;

----Q5.List unique movie ratings.

SELECT 
      DISTINCT rating 
FROM film;


----Q6.Find all customers from London

SELECT 
      first_name, 
	  last_name, 
	  city 
FROM customer
JOIN address
    ON customer.address_id = address.address_id 
JOIN city 
    ON address.city_id = city.city_id 
WHERE city LIKE 'London%';



---- Q7.Show all payments greater than 8

SELECT 
      payment_id, 
	  customer_id, 
	  amount 
from payment
WHERE amount > 8;

-----Q8.Count total films in each rating

SELECT 
     rating, 
	 count(title) 
FROM film
GROUP BY rating;


----Q9.Display films sorted by rental duration

SELECT 
      title, 
	  rental_duration 
from film
ORDER BY rental_duration ASC;

----Q10.Show first 20 rentals with rental date.

SELECT 
      rental_id, 
	  rental_date 
FROM rental
ORDER BY rental_date ASC
LIMIT 20;


























