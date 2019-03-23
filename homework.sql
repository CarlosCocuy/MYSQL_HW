-- Carlos Cocuy --
-- SQL Homework --
USE sakila;

-- 1a. Display the first and last names of all actors from the table actor --
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name. --
SELECT upper(concat(first_name,' ', last_name)) AS 'Actor Name' FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information? --
SELECT actor_id, first_name, last_name FROM ACTOR WHERE FIRST_NAME = 'JOE';

-- 2b. Find all actors whose last name contain the letters GEN: --
SELECT actor_id, first_name, last_name FROM ACTOR WHERE last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order: --
SELECT actor_id, first_name, last_name FROM ACTOR WHERE last_name like '%LI%' 
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China: --
SELECT country_id, country FROM COUNTRY WHERE country in ('Afghanistan', 'Bangladesh',  'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant). --
ALTER TABLE COUNTRY
ADD description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column. --
ALTER TABLE COUNTRY
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name. --
SELECT last_name, COUNT(last_name) as count 
FROM actor GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors --
SELECT last_name, COUNT(last_name) as count 
FROM actor 
GROUP BY last_name
HAVING COUNT(last_name) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record. --
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. --
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it? --
SHOW CREATE TABLE Address;

 
-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address: --
SELECT staff.first_name, staff.last_name, address.address
FROM staff JOIN address ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment. --
Select staff.first_name, staff.last_name, sum(payment.amount)
FROM staff JOIN payment ON staff.staff_id = payment.staff_id
group by staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join. --
SELECT film.title, COUNT(film_actor.actor_id)
FROM film JOIN film_actor ON film.film_id =film_actor.film_id 
GROUP BY film.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system? --
Select COUNT(inventory.film_id) AS 'Copies of Hunchback Impossible'
FROM film RIGHT JOIN inventory on film.film_id =inventory.film_id 
WHERE film.title = 'Hunchback Impossible';


-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name: --
SELECT C.FIRST_NAME, C.LAST_NAME, SUM(P.AMOUNT)
FROM CUSTOMER AS C JOIN PAYMENT AS P
ON C.CUSTOMER_ID = P.CUSTOMER_ID
GROUP BY C.CUSTOMER_ID
ORDER BY C.LAST_NAME;

/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
*/
SELECT title FROM film
WHERE title LIKE "k%" OR title LIKE "q%" AND language_id in(
SELECT language_id FROM language WHERE name = 'english');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip. --
SELECT FIRST_NAME, LAST_NAME FROM actor 
WHERE actor_id in ( SELECT actor_id FROM film_actor
WHERE film_id in (SELECT film_id FROM film WHERE title = 'Alone Trip'));

/* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and 
email addresses of all Canadian customers. Use joins to retrieve this information. */
SELECT cu.first_name, cu.last_name, co.country
FROM customer cu JOIN address a ON cu.address_id=a.address_id
JOIN city ci ON ci.city_id = a.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Canada';
/* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
 Identify all movies categorized as family films. */
SELECT title from film WHERE film_id in(
SELECT film_id from film_category WHERE category_id in(
SELECT category_id from category where name = 'family'));

-- 7e. Display the most frequently rented movies in descending order. --
SELECT title, (SELECT COUNT(*) FROM rental JOIN INVENTORY ON RENTAL.INVENTORY_ID = INVENTORY.INVENTORY_ID
WHERE FILM.FILM_ID = INVENTORY.FILM_ID ) as num_rented
FROM FILM
ORDER BY num_rented DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in. --
SELECT store_id,  SUM(amount) AS 'Business (in dollars)'
FROM PAYMENT AS P JOIN  STAFF AS S ON P.STAFF_ID = S.STAFF_ID
GROUP BY store_id;

-- 7g. Write a query to display for each store its store ID, city, and country. --
SELECT store_id, city, country
FROM store JOIN address ON store.address_id=address.address_id
JOIN city ON city.city_id = address.city_id
JOIN country ON country.country_id = city.country_id;

/* 7h. List the top five genres in gross revenue in descending order. 
(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.) */
SELECT c.name as Category, sum(amount) as Revenue
FROM category c JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p on p.rental_id = r.rental_id
GROUP BY Category
ORDER by Revenue DESC
LIMIT 5;

/*8a. In your new role as an executive, you would like to have an easy way of viewing the 
Top five genres by gross revenue. Use the solution from the problem above to create a view. 
If you haven't solved 7h, you can substitute another query to create a view. */
CREATE VIEW `Profitable Genres` AS 
SELECT c.name as Category, sum(amount) as Revenue
FROM category c JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p on p.rental_id = r.rental_id
GROUP BY Category
ORDER by Revenue DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a? --
SELECT * FROM `Profitable Genres`;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it. --
DROP VIEW `Profitable Genres`;