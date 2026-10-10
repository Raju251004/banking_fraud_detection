# Banking Fraud Detection SQL Project

This project contains a synthetic banking dataset and a MySQL schema designed for SQL learning, practice, and fraud-analysis use cases. It models a simplified banking environment with customers, accounts, branches, transactions, devices, merchants, login attempts, and fraud alerts.

## Project purpose

The repository is intended to support:

- SQL practice for beginners and intermediate users
- Join and aggregation exercises
- Fraud detection and transaction risk analysis
- Database schema design using real-world banking concepts
- Exploration of data relationships across customers, accounts, devices, and transactions

## Files in this repository

### SQL scripts

- `creating_table.sql`  
  Creates the `banking_fraud_detection` database and all tables with primary keys, foreign keys, indexes, and check constraints.

- `banking_fraud_sql_practice_questions_upto_joins.sql`  
  Contains SQL practice questions covering SELECT, WHERE, ORDER BY, aggregation, and joins.

### Data files

The CSV files represent the populated tables used in the database:

- `customers.csv` — customer master data
- `account_types.csv` — account product types
- `branches.csv` — branch locations and metadata
- `merchants.csv` — merchant records and categories
- `locations.csv` — ATM/POS/branch/mobile/online locations
- `devices.csv` — customer device information
- `transaction_types.csv` — transaction categories and types
- `fraud_rules.csv` — fraud detection rules
- `accounts.csv` — customer account records
- `transactions.csv` — transaction history
- `fraud_alerts.csv` — fraud alerts triggered by rules
- `login_attempts.csv` — login success/failure events
- `account_status_history.csv` — account status changes over time

## Database schema overview

The schema includes 13 core tables:

1. `customers`  
   Stores personal/identity data for each customer.

2. `account_types`  
   Lookup table for account products such as savings, current, credit, or premium accounts.

3. `branches`  
   Banking branch metadata such as city, state, manager, and address.

4. `merchants`  
   Merchant information, category, city, and risk score.

5. `locations`  
   Geographic and operational locations such as ATMs, branches, POS terminals, and online/mobile channels.

6. `devices`  
   Device registry, including type, OS, browser, and status.

7. `transaction_types`  
   Defines the type of financial transaction.

8. `fraud_rules`  
   Business rules used to detect suspicious or risky transactions.

9. `accounts`  
   Customer account master information linked to customers, branches, and account types.

10. `transactions`  
    Financial event history for each account, including amount, merchant, location, device, and status.

11. `fraud_alerts`  
    Rules triggered for suspicious transactions with risk score and alert status.

12. `login_attempts`  
    Authentication events for accounts and devices, useful for security analysis.

13. `account_status_history`  
    Timeline of status changes for accounts over time.

## Relationship model

The design follows a realistic banking data model:

- Customers have one or many accounts
- Accounts belong to a customer, account type, and branch
- Transactions belong to an account, merchant, location, device, and transaction type
- Fraud alerts are linked to transactions and fraud rules
- Login attempts are linked to accounts, devices, and locations
- Account status history tracks changes in account lifecycle

## Dataset size

The data is synthetic but fairly rich and varied. Based on the CSV files:

- 500 customers
- 700 accounts
- 20 branches
- 200 merchants
- 30 locations
- 700 devices
- 6,674 transactions
- 400 fraud alerts
- 2,935 login attempts
- 1,149 account status history records

## Setup instructions

### 1. Create the database

Run the schema creation script in MySQL:

```sql
mysql -u root -p < creating_table.sql
```

### 2. Import the CSV files

Use MySQL Workbench or the `LOAD DATA INFILE` command to import each CSV into the matching table. Example:

```sql
LOAD DATA INFILE 'customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

Repeat for the remaining CSV files using the matching table names.

## Example SQL use cases

### Find customers by state

```sql
SELECT *
FROM customers
WHERE state = 'Tamil Nadu';
```

### Check transaction totals by status

```sql
SELECT transaction_status, COUNT(*) AS transaction_count
FROM transactions
GROUP BY transaction_status;
```

### Join customer and account data

```sql
SELECT c.customer_id, c.first_name, c.last_name, a.account_number
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id;
```

### Identify fraud alerts with rule details

```sql
SELECT fa.alert_id, fr.rule_name, fr.risk_level, fa.risk_score
FROM fraud_alerts fa
JOIN fraud_rules fr ON fa.fraud_rule_id = fr.fraud_rule_id;
```

## Learning focus

This project is especially useful for practicing:

- `SELECT` statements
- `WHERE` filters
- `GROUP BY` and aggregation
- `HAVING` clauses
- `INNER JOIN` and `LEFT JOIN`
- multi-table data analysis
- fraud and risk detection logic

## Notes

- The dataset is synthetic and designed for training purposes.
- The schema uses MySQL 8.x syntax.
- The project is organized for easy SQL exploration without requiring a large enterprise data warehouse.

## Summary

This repository provides a practical, realistic SQL dataset for learning how to analyze banking data, detect suspicious activity patterns, and write joined analytical queries across multiple related tables.
