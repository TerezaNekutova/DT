--TASK 1--
--Write query which will match contacts and orders to our customers

--Because I work with result in following queries I will create temp table for it
drop table if exists customers_with_orders;

CREATE TEMPORARY TABLE customers_with_orders AS 
select * from customers cst
left join contacts con on con.customer_id=cst.customer_id
left join orders o on o.customer_id=cst.customer_id;
--where order_id is not NULL;

select * from customers_with_orders;

--TASK 2--
-- There is  suspision that some orders were wrongly inserted more times. Check if there are any duplicated orders. If so, return duplicates with the following details:
-- first name, last name, email, order id and item
select
first_name,
last_name,
email,
order_id,
item
from customers_with_orders
GROUP by first_name, last_name, email, order_id, item
having count(*) > 1;


--TASK 3-	
-- As you found out, there are some duplicated order which are incorrect, adjust query from previous task so shows following:
-- Shows first name, last name, email, order id and item
-- Does not show duplicates.
-- Order result by customer last name

-- Query in case I still work with temp table
--select 
--DISTINCT(first_name) as first_name,
--last_name,
--email,
--order_id,
--item
--from customers_with_orders
--order by last_name;

-- Adjusted query
select 
DISTINCT(first_name) as first_name,
last_name,
email,
order_id,
item
from customers cst
left join contacts con on con.customer_id=cst.customer_id
left join orders o on o.customer_id=cst.customer_id
--where order_id is not NULL
order by last_name;


--TASK 4--
--Our company distinguishes orders to sizes by value like so:
--order with value less or equal to 25 euro is marked as SMALL
--order with value more than 25 euro but less or equal to 100 euro is marked as MEDIUM
--order with value more than 100 euro is marked as BIG
--Write query which shows only three columns: full_name (first and last name divided by space), order_id and order_size
--Make sure the duplicated values are not shown
select 
DISTINCT(first_name || ' ' || last_name) as full_name,
order_id,
case when order_value <= 25 then 'SMALL'
     WHEN order_value <= 100 THEN 'MEDIUM'
     when order_value > 100 then 'BIG'
     end as order_size
from customers_with_orders;

--TASK 5--
-- Filter out all items from orders table which containt in their name 'ea' or start with 'Key'
select * from orders
where item not like '%ea%' AND item not like 'Key%';

--TASK 6--
-- Please find out if some customer was referred by already existing customer
-- Return results in following format "Customer Last name Customer First name" "Last name First name of customer who recomended the new customer"
select 
ref.last_name || ' ' || ref.first_name as referred_customer,
c0.last_name || ' ' || c0.first_name as referee
from customers ref
left join customers c0 on ref.referred_by_id=c0.customer_id
where ref.referred_by_id <> '';



