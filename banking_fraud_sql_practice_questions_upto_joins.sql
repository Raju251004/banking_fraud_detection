-- ============================================================
-- Banking Transaction Fraud Detection & Analytics System
-- MySQL 8.x | Database: banking_fraud_detection
--
-- Instructions:
-- 1. Select the banking_fraud_detection database before running queries.
-- ============================================================

USE banking_fraud_detection;

-- ============================================================
-- SECTION A — BASIC SQL
-- SELECT, WHERE, ORDER BY, LIMIT, DISTINCT
-- Tables used: customers, transactions, accounts
-- ============================================================


-- Q1. List all customers whose state is 'Tamil Nadu'.
-- Concept: WHERE

select * 
from customers 
where state= 'Tamil Nadu';

-- Q2. Find all transactions with a transaction_amount greater than ₹50,000.
-- Concept: WHERE
select * 
from transactions 
where transaction_amount > 50000;

-- Q3. List the 10 most recently dated transactions, most recent first.
-- Concept: ORDER BY, LIMIT
select sum(transaction_amount) as transation_total 
from transactions 
order by transaction_date desc limit 10;

-- Q4. Find all distinct merchant_category values used across all merchants.
-- Concept: DISTINCT
select distinct merchant_category
from merchants;

-- Q5. List all accounts where account_status is 'suspended'.
-- Concept: WHERE
select * 
from accounts
where account_status= 'suspended';

-- Q6. List all customers, ordered by customer_since (oldest customer first).
-- Concept: ORDER BY
select*
from customers
order by customer_since ASC;

-- Q7. Find all transactions where transaction_status is 'failed',
--     showing only transaction_id, account_id, and transaction_amount.
-- Concept: WHERE, column selection
select transaction_id, account_id, transaction_amount
from transactions
where transaction_status = 'failed';

-- ============================================================
-- SECTION B — AGGREGATION
-- COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING
-- Tables used: transactions, accounts, devices
-- ============================================================

-- Q8. What is the total transaction amount across all transactions
--     in the system?
-- Concept: SUM
select sum(transaction_amount) as total_transaction_amount
from transactions;

-- Q9. How many transactions fall into each transaction_status
--     category (success, failed, pending)?
-- Concept: COUNT, GROUP BY
select transaction_status, count(*) as transaction_count
from transactions
group by transaction_status;

-- Q10. Find the average transaction_amount for each transaction_type_id.
-- Concept: AVG, GROUP BY
select transaction_type_id,
avg(transaction_amount) as average_transaction_amount
from transactions
group by transaction_type_id;

-- Q11. Which branch_id values have more than 30 accounts associated
--      with them?
-- Concept: COUNT, GROUP BY, HAVING
select branch_id, COUNT(*) AS account_count
from accounts
group by branch_id
having count(*) >30;

-- Q12. Count how many devices exist for each device_type.
-- Concept: COUNT, GROUP BY
select device_type, count(*) as device_count
from devices
group by device_type;

-- Q13. Find the minimum and maximum transaction_amount recorded
--      in the transactions table.
-- Concept: MIN, MAX
select min(transaction_amount) as minimum_transaction_amount,
       max(transaction_amount) as maximum_transaction_amount
from transactions;
-- Q14. For each account_id, count how many transactions it has,
--      but only show accounts with more than 15 transactions.
-- Concept: COUNT, GROUP BY, HAVING
select account_id, count(*) as transaction_count
from transactions
group by account_id
having COUNT(*) > 15;

-- ============================================================
-- SECTION C — BASIC JOINS
-- INNER JOIN
--
-- Tables used:
-- transactions + accounts + customers
-- accounts + branches + account_types
-- fraud_alerts + fraud_rules
-- merchants
-- devices
-- locations
-- ============================================================


-- Q15. List each transaction along with the first_name and last_name
--      of the customer who made it (join transactions to accounts
--      to customers).
select t.transaction_id,
c.first_name,
c.last_name
from transactions as t
join accounts as a
on t.account_id = a.account_id
join customers as c
on a.customer_id = c.customer_id;

-- Q16. Show each account with its branch_name and account_type_name.
-- Concept: INNER JOIN

select a.account_id,
b.branch_name,
at.account_type_name
from accounts as a
join branches as b
on a.branch_id = b.branch_id
inner join account_types as at
on a.account_type_id = at.account_type_id;

-- Q17. List all fraud alerts along with the rule_name and risk_level
--      from fraud_rules.
-- Concept: INNER JOIN
select fa.alert_id,
fr.rule_name,
fr.risk_level
from fraud_alerts as fa
join fraud_rules as fr
on fa.fraud_rule_id = fr.fraud_rule_id;

-- Q18. Each transaction with merchant_name and merchant_category.
select t.transaction_id,
m.merchant_name,
m.merchant_category
from transactions as t
join merchants AS m
ON t.merchant_id = m.merchant_id;


-- Q19. Each login_attempt with device_type and location city.

select la.login_attempt_id,
d.device_type,
l.city
from login_attempts as la
join devices as d
on la.device_id = d.device_id
join locations as l
on la.location_id = l.location_id;


-- Q20. Transactions above ₹100,000 with customer's name
--      and branch city.

select t.transaction_id,
t.transaction_amount,
c.first_name,
c.last_name,
b.city
from transactions as t
join accounts as a
on t.account_id = a.account_id
join customers as c
on a.customer_id = c.customer_id
join branches as b
on a.branch_id = b.branch_id
where t.transaction_amount > 100000;

-- ============================================================
-- SECTION D — LEFT JOIN
-- ============================================================

-- Q21. All customers and their accounts,
--      including customers with zero accounts.
select c.customer_id,
c.first_name,
c.last_name,
a.account_id,
a.account_number
from customers as c
left join accounts as a
on c.customer_id = a.customer_id;

-- Q22. All merchants with transaction count,
--      including merchants with zero transactions.

select m.merchant_id,
m.merchant_name,
count(t.transaction_id) as transaction_count
from merchants as m
left join transactions as t
on m.merchant_id = t.merchant_id
group by m.merchant_id, m.merchant_name;


-- Q23. All fraud rules with number of triggered alerts,
--      including rules with zero alerts.

select fr.fraud_rule_id,
fr.rule_name,
count(fa.alert_id) as alert_count
from fraud_rules as fr
left join fraud_alerts as fa
on fr.fraud_rule_id = fa.fraud_rule_id
group by fr.fraud_rule_id, fr.rule_name;


-- Q24. All devices with number of transactions,
--      including devices never used for a transaction.

select d.device_id,
d.device_type,
count(t.transaction_id) AS transaction_count
from devices as d
left join transactions as t
on d.device_id = t.device_id
group by d.device_id, d.device_type;

-- ============================================================
-- SECTION E — MULTI-TABLE JOINS
-- ============================================================

-- Q25. Every fraud alert with customer's name,
--      transaction amount, transaction date, and rule name.

select fa.alert_id,
c.first_name,
c.last_name,
t.transaction_amount,
t.transaction_date,
fr.rule_name
from fraud_alerts as fa
join transactions as t
on fa.transaction_id = t.transaction_id
join accounts as a
on t.account_id = a.account_id
join customers as c
on a.customer_id = c.customer_id
join fraud_rules as fr
on fa.fraud_rule_id = fr.fraud_rule_id;

-- Q26. Each transaction with account_number,
--      customer full name, and branch city.

select t.transaction_id,
a.account_number,
concat(c.first_name, ' ', c.last_name) as customer_name,
b.city as branch_city
from transactions as t
inner join accounts as a
on t.account_id = a.account_id
inner join customers as c
on a.customer_id = c.customer_id
inner join branches as b
on a.branch_id = b.branch_id;

-- Q27. High-risk merchants with transaction count
--      and total transaction amount.

select m.merchant_id,
m.merchant_name,
count(t.transaction_id) as transaction_count,
sum(t.transaction_amount) as total_transaction_amount
from merchants as m
inner join transactions as t
on m.merchant_id = t.merchant_id
where m.risk_level = 'high'
group by m.merchant_id, m.merchant_name;

-- Q28. Failed login attempts with customer's name
--      and device_type.

select la.login_attempt_id,
c.first_name,
c.last_name,
d.device_type
from login_attempts as la
inner join accounts as a
on la.account_id = a.account_id
inner join customers as c
on a.customer_id = c.customer_id
inner join devices as d
on la.device_id = d.device_id
where la.login_status = 'failed';
-- ============================================================
-- q29. using case, label every transaction as 'low' (amount < 5,000),
--      'medium' (5,000–49,999), or 'high' (50,000+).

select transaction_id,
transaction_amount,
   case
   when transaction_amount < 5000 then 'low'
   when transaction_amount < 50000 then 'medium'
   else 'high'
   end as amount_category
from transactions;


-- q30. using case, convert each account's account_status into a friendlier label —
--      'active' → 'active', 'suspended' → 'under review', 'closed' → 'closed account'.

select account_id,
account_status,
   case
   when account_status = 'active' then 'active'
   when account_status = 'suspended' then 'under review'
   when account_status = 'closed' then 'closed account'
   end as status_label
from accounts;


-- q31. list all fraud_alerts, showing 'not yet reviewed'
--      in place of a null reviewed_date.

select alert_id,
fraud_rule_id,
transaction_id,
coalesce(reviewed_date, 'not yet reviewed') as reviewed_date
from fraud_alerts;


-- q32. list all fraud_alerts, showing 'pending'
--      in place of a null resolution value.

select alert_id,
fraud_rule_id,
transaction_id,
coalesce(resolution, 'pending') as resolution
from fraud_alerts;


-- q33. find all customers who have never made a single transaction
--      (hint: subquery against accounts + transactions).

select *
from customers
where customer_id not in (
select a.customer_id
from accounts as a
inner join transactions as t
	on a.account_id = t.account_id
);


-- q34. find all transactions where transaction_amount is greater
--      than the average transaction_amount across the entire transactions table.

select *
from transactions
where transaction_amount > (
select avg(transaction_amount)
from transactions
);


-- q35. find all merchants who have never appeared in a single transaction.

select *
from merchants as m
where not exists (
select 1
from transactions as t
where t.merchant_id = m.merchant_id
);


-- q36. find all accounts where current_balance is below the minimum_balance
--      defined for that account's account_type.

select *
from accounts as a
where current_balance < (
select at.minimum_balance
from account_types as at
where at.account_type_id = a.account_type_id
);


-- q37. for each transaction, flag it as 'above own average' if its amount
--      is greater than that specific account's own average transaction amount.

select t.transaction_id,
t.account_id,
t.transaction_amount,
case
when t.transaction_amount > (
   select avg(t2.transaction_amount)
   from transactions as t2
   where t2.account_id = t.account_id
)
then 'above own average'
else 'not above own average'
end as amount_flag
from transactions as t;


-- q38. for each customer, find their single most recent transaction date
--      using a correlated subquery instead of group by + max.

select c.customer_id,
c.first_name,
c.last_name,
(
select max(t.transaction_date)
from accounts as a
inner join transactions as t
on a.account_id = t.account_id
where a.customer_id = c.customer_id
) as most_recent_transaction_date
from customers as c;


-- q39. find all customers whose most recent transaction amount is greater
--      than their own historical average transaction amount.

select c.customer_id,
c.first_name,
c.last_name
from customers as c
where (
select t.transaction_amount
from accounts as a
inner join transactions as t
on a.account_id = t.account_id
where a.customer_id = c.customer_id
order by t.transaction_date desc
limit 1
) > (
select avg(t2.transaction_amount)
from accounts as a2
inner join transactions as t2
on a2.account_id = t2.account_id
where a2.customer_id = c.customer_id
);


-- q40. using union, build one combined list of 'flagged accounts':
--      accounts that have at least one fraud_alert, OR
--      accounts with 3 or more failed login_attempts.

select a.account_id
from accounts as a
inner join transactions as t
on a.account_id = t.account_id
inner join fraud_alerts as fa
on t.transaction_id = fa.transaction_id

union

select a.account_id
from accounts as a
inner join login_attempts as la
on a.account_id = la.account_id
where la.login_status = 'failed'
group by a.account_id
having count(la.login_attempt_id) >= 3;


-- q41. using union all, combine all transactions above 100,000
--      with all transactions involving high-risk merchants,
--      keeping duplicates if a transaction matches both conditions.

select *
from transactions
where transaction_amount > 100000

union all

select t.*
from transactions as t
inner join merchants as m
on t.merchant_id = m.merchant_id
where m.risk_level = 'high';


-- q42. using case together with a subquery, label each customer as
--      'high value customer' if their total transaction amount
--      exceeds the average total transaction amount across all customers,
--      otherwise 'regular customer'.

select c.customer_id,
c.first_name,
c.last_name,
case
when (
select coalesce(sum(t.transaction_amount), 0)
from accounts as a
inner join transactions as t
on a.account_id = t.account_id
where a.customer_id = c.customer_id
) > (
select avg(customer_total)
from (
select a2.customer_id,
coalesce(sum(t2.transaction_amount), 0) as customer_total
from accounts as a2
left join transactions as t2
on a2.account_id = t2.account_id
group by a2.customer_id
) as customer_totals
)
then 'high value customer'
else 'regular customer'
end as customer_category
from customers as c;
-- ============================================================

-- q43. write a cte that computes the total transaction_amount per account_id,
--      then select only the accounts where that total exceeds 500,000.

with account_totals as (
select account_id,
sum(transaction_amount) as total_amount
from transactions
group by account_id
)
select account_id,
total_amount
from account_totals
where total_amount > 500000;


-- q44. write a cte that computes each customer's total transaction count,
--      then join it back to customers to display customer name alongside their count.

with customer_transaction_count as (
select a.customer_id,
count(t.transaction_id) as transaction_count
from accounts as a
left join transactions as t
on a.account_id = t.account_id
group by a.customer_id
)
select c.customer_id,
c.first_name,
c.last_name,
coalesce(ctc.transaction_count, 0) as transaction_count
from customers as c
left join customer_transaction_count as ctc
on c.customer_id = ctc.customer_id;


-- q45. for each account, assign a row number to its transactions ordered
--      by transaction_date descending (most recent = 1).
--      use this to isolate each account's single most recent transaction.

with ranked_transactions as (
select t.*,
row_number() over (
partition by account_id
order by transaction_date desc
) as row_num
from transactions as t
)
select *
from ranked_transactions
where row_num = 1;


-- q46. within each fraud_rule_id, use row_number to rank that rule's
--      fraud_alerts by risk_score descending, identifying the single
--      highest-risk alert per rule.

with ranked_alerts as (
select fa.*,
row_number() over (
partition by fraud_rule_id
order by risk_score desc
) as row_num
from fraud_alerts as fa
)
select *
from ranked_alerts
where row_num = 1;


-- q47. rank all customers by their total transaction amount (highest first)
--      using rank(), so tied totals share the same rank and the next rank
--      number is skipped accordingly.

with customer_totals as (
select a.customer_id,
sum(t.transaction_amount) as total_amount
from accounts as a
join transactions as t
on a.account_id = t.account_id
group by a.customer_id
)
select c.customer_id,
c.first_name,
c.last_name,
ct.total_amount,
rank() over (
order by ct.total_amount desc
) as customer_rank
from customer_totals as ct
join customers as c
on ct.customer_id = c.customer_id;


-- q48. rank all merchants by total transaction volume using dense_rank()
--      instead, so tied merchants share a rank with no gap in the following
--      rank number.

with merchant_totals as (
select m.merchant_id,
m.merchant_name,
sum(t.transaction_amount) as total_amount
from merchants as m
join transactions as t
on m.merchant_id = t.merchant_id
group by m.merchant_id, m.merchant_name
)
select merchant_id,
merchant_name,
total_amount,
dense_rank() over (
order by total_amount desc
) as merchant_rank
from merchant_totals;


-- q49. for each account, use lag() to show the previous transaction's amount
--      alongside the current transaction's amount, ordered by transaction_date.

select transaction_id,
account_id,
transaction_date,
transaction_amount,
lag(transaction_amount) over (
partition by account_id
order by transaction_date
) as previous_transaction_amount
from transactions;


-- q50. for each account, use lead() to show the next transaction's
--      transaction_date alongside the current row.

select transaction_id,
account_id,
transaction_date,
lead(transaction_date) over (
partition by account_id
order by transaction_date
) as next_transaction_date
from transactions;


-- q51. combine lag() with timestampdiff(minute, ...) to compute the number
--      of minutes between each transaction and the previous transaction
--      for the same account. flag any row where that gap is 3 minutes or less.

with transaction_gaps as (
select transaction_id,
account_id,
transaction_date,
lag(transaction_date) over (
partition by account_id
order by transaction_date
) as previous_transaction_date
from transactions
)
select transaction_id,
account_id,
transaction_date,
previous_transaction_date,
timestampdiff(
minute,
previous_transaction_date,
transaction_date
) as gap_minutes,
case
when timestampdiff(
minute,
previous_transaction_date,
transaction_date
) <= 3
then 'rapid multiple transactions'
else 'normal'
end as transaction_flag
from transaction_gaps;


-- q52. calculate a running total of transaction_amount for each account,
--      ordered by transaction_date.

select transaction_id,
account_id,
transaction_date,
transaction_amount,
sum(transaction_amount) over (
partition by account_id
order by transaction_date
) as running_total
from transactions;


-- q53. for each transaction, show what percentage of that account's total
--      transaction amount this single transaction represents.

select transaction_id,
account_id,
transaction_amount,
round(
transaction_amount * 100.0 /
sum(transaction_amount) over (
partition by account_id
),
2
) as percentage_of_account_total
from transactions;


-- q54. for each transaction, show that account's average transaction_amount
--      then flag any row where the transaction_amount is more than 3 times
--      that average.

select transaction_id,
account_id,
transaction_amount,
avg(transaction_amount) over (
partition by account_id
) as account_average,
case
when transaction_amount >
3 * avg(transaction_amount) over (
	partition by account_id
)
then 'unusual transaction amount'
else 'normal'
end as transaction_flag
from transactions;


-- q55. using a cte plus row_number(), return exactly one row per account:
--      their most recent transaction.

with ranked_transactions as (
select t.*,
row_number() over (
partition by account_id
order by transaction_date desc
) as row_num
from transactions as t
)
select *
from ranked_transactions
where row_num = 1;


-- q56. using a cte plus rank(), find the top 3 highest-value transactions
--      for every customer. customers with fewer than 3 transactions
--      should show all of theirs.

with ranked_transactions as (
select t.transaction_id,
a.customer_id,
t.transaction_amount,
t.transaction_date,
rank() over (
partition by a.customer_id
order by t.transaction_amount desc
) as transaction_rank
from transactions as t
join accounts as a
on t.account_id = a.account_id
)
select *
from ranked_transactions
where transaction_rank <= 3;