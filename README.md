# SQL Handbook
This was supposed to be a repository created for coding challenges proposed in Dio's SQL Database Specialist bootcamp, but i decided to transform it into a guide to core SQL concepts along with some example codes to those concepts. Thus, this project is far from done. 
If you find any of my notes incomplete or incorrect, feel free to let me know. Also note that I'm using MariaDB here.


## Database Schema Design
Below is the Schema Design for the database. It was created to fit Kaggle's Bike Shop dataset, so I'd like to credit Dillon Myrick for creating it.
The original dataset can be found ![here](https://www.kaggle.com/datasets/dillonmyrick/bike-store-sample-database).

![dbdesign](pics/swappy-20240321_213504.png)

## Coding the Database
Below is the code used to create the database. It can also be found as creation.sql in this repository.

```sql

CREATE DATABASE bike_shop;

USE bike_shop;

CREATE TABLE brands(
  brand_id INT AUTO INCREMENT NOT NULL PRIMARY KEY,
  brand_name VARCHAR(25)
);

CREATE TABLE customers(
  customer_id AUTO INCREMENT NOT NULL PRIMARY KEY,
  first_name VARCHAR(25),
  last_name VARCHAR(25),
  phone VARCHAR(25),
  email VARCHAR(50),
  street VARCHAR(25),
  state VARCHAR(2),
  zip_code INT,
  city VARCHAR(25)
);


CREATE TABLE stores(
  store_id INT AUTO INCREMENT NOT NULL PRIMARY KEY,
  store_name VARCHAR(25),
  phone VARCHAR(25),
  email VARCHAR(50),
  street VARCHAR(25),
  city VARCHAR(25),
  state VARCHAR(2),
  zip_code INT,
);

CREATE TABLE categories(
  category_id INT AUTO INCREMENT NOT NULL PRIMARY KEY,
  category_name VARCHAR(25)
);

CREATE TABLE staffs(
  staff_id INT AUTO INCREMENT NOT NULL PRIMARY KEY,
  first_name VARCHAR(25),
  last_name VARCHAR(25),
  email VARCHAR(50),
  phone VARCHAR(25),
  active INT,
  store_id INT,
  manager_id INT NOT NULL,
  CONSTRAINT FOREIGN KEY(store_id) REFERENCES stores(store_id)
);

CREATE TABLE orders(
  order_id INT AUTO INCREMENT NOT NULL PRIMARY KEY,
  customer_id INT,
  order_status INT,
  oder_date DATE,
  required_date DATE,
  shipped_date DATE,
  store_id INT,
  staff_id INT,
  CONSTRAINT FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
  CONSTRAINT FOREIGN KEY(store_id) REFERENCES stores(store_id),
  CONSTRAINT FOREIGN KEY(staff_id) REFERENCES staffs(staff_id)
);

CREATE TABLE stocks(
  store_id INT,
  product_id INT,
  quantity INT,
  CONSTRAINT FOREIGN KEY(store_id) REFERENCES stores(store_id),
  CONSTRAINT FOREIGN KEY(product_id) REFERENCES products(product_id)
);

CREATE TABLE products(
  product_id INT AUTO INCREMENT NOT NULL PRIMARY KEY,
  product_name VARCHAR(25),
  brand_id INT,
  category_id INT,
  model_year INT,
  list_price DECIMAL,
  CONSTRAINT FOREIGN KEY(brand_id) REFERENCES brands(brand_id),
  CONSTRAINT FOREIGN KEY(category_id) REFERENCES categories(category_id)
);

CREATE TABLE order_items(
  order_id INT,
  item_id INT,
  product_id INT,
  quantity INT,
  list_price DECIMAL,
  discount DECIMAL,
  CONSTRAINT FOREIGN KEY(product_id) REFERENCES products(product_id)
);
```

## Populating the database
As mentioned above, the database was created to fit the Bike Shop Dataset. The data was imported to each table in DBeaver using the built-in import CSV tool. The process was pretty straight-foward - almost no data cleaning was needed. Some null values were filled, such as the field *manager_id* present in the table *staffs*, where the null values were filled with zeroes. The reason for that decision will be discussed in the procedures section.

## Indexing

### Why index the data?
If we want to recover information about the items which price is greater than or equal to USD 1000, we can do it as such:

```sql
SELECT product_name, list_price FROM products WHERE list_price >= 1000;
```

Altough it is a very simple query, it would also be slow if we had a database with millions of entries. That happens because the underlying algorithm used in a simple search, such as the mentioned above, is a sequential search. If you want to recover a value that is present at the end of the table, it will iterate through the full table until it finds it. 
On the other hand, when you add indexes to your tables, the search will be done using BTree or Hash algorithm (more details on that below), reducing the time needed for data retrieval substantially for very large datasets.

For that reason, we can use function indexes such as the presented below to speed up the process:

```sql
CREATE INDEX list_price_over_thousand_idx ON products(list_price >= 1000);
```

And for the prices below USD 1000:

```sql
CREATE INDEX list_price_below_thousand_idx ON products(list_price < 1000);
```
### Creating our indexes
Altough indexes speed up the data retrieval process, it slows down the data insertion and update of tables. That happens because the data will also be added to the applicable indexes. Hence, it should be used in tables that will not be frequently updated.
Indexing is also unnecessary with a small amount of data, such as we have in our database here. Just for the purpose of demonstration, let's suppose we have a very large number of tuples in each of our tables, so indexing would be necessary.

Suppose our business is growing exponentially and new clients are being added to our database frequently. Indexing the customer table would not be a great idea, since it would be updated constantly.
A better candidate for indexing would be our stores table, since the number of new stores being inserted into our database would be a fraction of the customers.

If one wants to retrieve information about the store based on it's name, it could be indexed as such:

```sql
CREATE INDEX store_name_idx ON stores(store_name)
```

Now to a more complex index. Suppose we want to recover information about staff members based on the combination of their first and last names.
```sql
CREATE INDEX full_name_idx
  ON staffs(first_name, last_name);
```
Creating an index with a code such as the presented above will default to a BTree algorithm. If a Hash algorithm is desired instead, it should be specified in me moment of creation, such as in the code below:

```sql
CREATE INDEX full_name_idx
  ON staffs(first_name, last_name)
   USING HASH;
```

For now, all the indexes present in our database will be using the default BTree algorithm. The indexes that were created here will be used in the DataViz section.

## Creating procedures
Simply put, procedures are functions that are stored in memory and can be called at any time to execute a set of instructions. It would be useful to recover a customer's e-mail address using his id. The following code generate such procedure in MariaDB:

 ```sql
DELIMITER $$

CREATE PROCEDURE recover_email(IN client_id INT)
BEGIN

  SELECT email FROM customers WHERE customer_id=client_id;

END $$
```
Now calling this procedure using the CALL function passing the id 1 as argument yields the following result: </br>
![pic](pics/swappy-20240324_191031.png)

The table *staffs* only identifies managers by their id. We may also want to include their name in the table. First the column *full_name* has to be created.
```sql
ALTER TABLE staffs ADD COLUMN full_name VARCHAR(50);
```
The table *staffs* only has a few tuples, so we could insert values in the newly added *full_name* column by hand. Otherwise, if the table had millions of tuples, a procedure could be created to automatic update the column with the name of the manager based on his id. We could create such procedure with the following code:
```sql
DELIMITER $$
CREATE PROCEDURE auto_update_manager(IN id INT)
 BEGIN
  IF id = 0 THEN UPDATE staffs SET manager_name = 'No Manager' WHERE manager_id = id;
  ELSEIF id = 1 THEN UPDATE staffs SET manager_name = 'Robert' WHERE manager_id = id;
  ELSEIF id = 2 THEN UPDATE staffs SET manager_name = 'Christine' WHERE manager_id = id;
  ELSEIF id = 5 THEN UPDATE staffs SET manager_name = 'Carla' WHERE manager_id = id;
  ELSEIF id = 7 THEN UPDATE staffs SET manager_name = 'Luccas' WHERE manager_id = id;
  ELSE UPDATE staffs SET manager_name = 'No information' WHERE manager_id = id;
 END IF;
END $$
DELIMITER ;
```
Now if we call this procedure passing the id 1 as argument we get the following result: </br>
![pic2](pics/swappy-20240325_155011.png)
All the tuples where *manager_id* was equal to 1 had the column *manager_name* updated to Robert. The same could be done for all other ids.
Note that the procedure could also be created using the CASE statement:
```sql
DELIMITER $$
CREATE PROCEDURE auto_update_manager(IN id INT)
 BEGIN
  CASE id
   WHEN id = 0 THEN UPDATE staffs SET manager_name = 'No Manager' WHERE manager_id = id;
   WHEN id = 1 THEN UPDATE staffs SET manager_name = 'Robert' WHERE manager_id = id;
   WHEN id = 2 THEN UPDATE staffs SET manager_name = 'Christine' WHERE manager_id = id;
   WHEN id = 5 THEN UPDATE staffs SET manager_name = 'Carla' WHERE manager_id = id;
   WHEN id = 7 THEN UPDATE staffs SET manager_name = 'Luccas' WHERE manager_id = id;
   ELSE UPDATE staffs SET manager_name = 'No information' WHERE manager_id = id;
 END CASE;
END $$
DELIMITER ;
```

## Adding Views
Whenever an order is made, the store owner must know where to ship and who bought which item. we do not need to provide full acess to our database in order for the store owner to retrieve this information. Instead, a view could be created, which will contain only the information needed for this specific context. A view for this case could be created as such:

```sql
CREATE VIEW santa_cruz_orders AS
 SELECT
  CONCAT(c.first_name, ' ', c.last_name) as name, CONCAT(c.street, '- ', c.city, ', ', c.state) as adress, c.zip_code, p.product_name, oi.quantity, oi.order_id
 FROM
  customers as c, products as p, order_items as oi, orders as o, stores as s
 WHERE
  c.customer_id = o.customer_id AND o.order_id = oi.order_id AND oi.product_id = p.product_id AND store_id = 1;
```

The same could be done for all other stores, just modifying the *store_id* and the view's name.
A simple select all statement using this view returns a table like this: </br>
![pic5](pics/swappy-20240325_164715.png)

## Creating Triggers
Based on the way our database is structured, what needs to happen whenever an orders is made? We have a stocks table, so an amount equal to the ordered needs to be subtracted from this table.
```sql
DELIMITER $$

CREATE TRIGGER auto_update_stocks
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
 UPDATE stocks SET stocks.quantity = stocks.quantity - order_items.quantity WHERE order_items.product_id = stocks.product_id;
END;
$$

DELIMITER ;
```
This will automatically update the stocks table. We can also check if the stock is enough to supply the ordered amount. In case this is false, an error will be raised and the row will not be inserted.
```sql
DELIMITER $$

CREATE TRIGGER auto_check_stocks_tg
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN 
	IF order_items.quantity > stocks.quantity THEN SIGNAL SQLSTATE '45000';
END IF;
END;
$$

DELIMITER ;
```
## Isolation
Isolation level in databases, including MySQL (and MariaDB), defines how transactions interact with each other regarding visibility of data changes and the level of concurrency. It determines the degree to which one transaction's changes are visible to other concurrent transactions. Different isolation levels offer different trade-offs between data consistency, concurrency, and performance. MySQL supports the following standard isolation levels:

### READ UNCOMMITTED: 
This is the lowest isolation level. It allows a transaction to read data that has been modified by other transactions but not yet committed. It can lead to phenomena like dirty reads, non-repeatable reads, and phantom reads.

### READ COMMITTED: 
In this isolation level, a transaction can only read data that has been committed by other transactions. It eliminates dirty reads but still allows non-repeatable reads and phantom reads because data can be changed by other transactions between separate reads within the same transaction.

### REPEATABLE READ: 
This level ensures that within a transaction, the data remains consistent for the duration of the transaction. It prevents dirty reads and non-repeatable reads by holding read locks on all data read by the transaction until it is committed. However, it still allows phantom reads because new rows can be inserted by other transactions.

### SERIALIZABLE: 
This is the highest isolation level, providing strict transaction isolation. It ensures that transactions are executed as if they were executed serially, one after another, even though they may be executed concurrently. It prevents all types of anomalies (dirty reads, non-repeatable reads, and phantom reads) by placing a range lock on the entire data set the transaction accesses until the transaction is completed.

### Dirty, Non-Repeatable and Phantom reads 
#### Dirty Reads:
A dirty read occurs when one transaction reads data that has been modified by another transaction but not yet committed. In other words, a transaction reads data from another transaction that may be rolled back later, resulting in the transaction reading "dirty" or uncommitted data. Dirty reads can lead to incorrect or inconsistent results because the changes being read might never be committed.

#### Non-Repeatable Reads:
A non-repeatable read occurs when a transaction re-reads data it has previously read within the same transaction, but the data has been modified or deleted by another transaction in the meantime.        This phenomenon results in the transaction seeing different values for the same data within the same transaction, leading to inconsistency. Non-repeatable reads can occur at isolation levels below REPEATABLE READ because they allow other transactions to modify the data being read.

#### Phantom Reads:
A phantom read occurs when a transaction re-executes a query and finds additional rows that were not present in the initial result set due to another transaction inserting new rows that match the query criteria. Unlike non-repeatable reads, which involve changes to existing rows, phantom reads involve the appearance of new rows that were not visible during the initial query execution. Phantom reads can occur at isolation levels below SERIALIZABLE because they allow other transactions to insert new rows that match the query criteria.

### The trade-off
It's important to carefully consider the requirements of the application and choose the appropriate isolation level accordingly. There's often a trade-off between data consistency and concurrency, so understanding the behavior of each isolation level is crucial in designing robust and efficient database systems. In our case, we don't wand two customers to be able to purchase the same item as it will lead do problems. At the same time, we don't want our customers to be locked while trying to make a purchase. Since all we care about for this example is if an item is avaliable or not in stock, we don't have to worry about Phantom Reads for now, so a Repeatable Read Isolation Level should do the trick for now.

### Setting and acessing the isolation level
To show the isolation level for the current session, you can use the code below:
```sql
SELECT @@tx_isolation;
```
This will return the isolation level for the current session. If you instead want to check the global isolation level, the following code returns that.
```sql
SELECT @@GLOBAL.tx_isolation;
```
This will return the current isolation.
If one wants to modify the Isolation Level for the session, it could be done with a simple SET statement:
```sql
SET SESSION tx_isolation = <ISOLATION_LEVEL>
```
In our case, we do not have to modify this variable, since Repeatable-Read is the default value for the Isolation Level on MariaDB.

## Adding transactions
Above we created a procedure that automatically deduces the amount ordered of a specific item. It is sensible to do so since we want to avoid selling an item that is no longer avaliable in stock. But what would happen if an order is cancelled? In the way that our database is structured, two tables must be updated. First, the *order_status* column in the *orders* table must be updated to the respective cancelled status code. After that, the ordered items should be added back to the *quantity* column in the *stocks* table. 
But what would happen if one of this update statements fail? We would have inconsistent information in our database - the *quantity* column in our *stocks* table would no longer reflect the real amount avaliable of that item. To solve this problem, a transaction can be set up so either both tables are updated or none, based on the atomicity principle. 
We can create such transaction as such:
```sql
DELIMITER $$
CREATE PROCEDURE update_order_status_proc(IN status INT, IN id INT)
BEGIN
DECLARE sql_error TINYINT DEFAULT FALSE;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_error = TRUE;
START TRANSACTION;
	UPDATE orders SET order_status = status WHERE order_id = id;
	UPDATE stocks SET quantity = quantity +
		(SELECT quantity FROM order_items WHERE order_id = id);
	IF sql_error = FALSE THEN
		COMMIT;
		SELECT 'Transaction sucessful' AS Result;
	ELSE
		ROLLBACK;
		SELECT 'Transaction error' AS Result;
	END IF;
END $$
DELIMITER ; 
```
Now calling this procedure passing the status code and id to the CALL function will only modify our database if both *orders* and *stocks* table are updated. If one of them fails to update, the IF block will throw an exception and no changes will be persisted.
Note that this will only work if autommit is diabled. If autocommit is enabled, it will persist the changes as soon as a statement is called. If it is disabled, it will wait for a COMMIT statement to do so. Autocommit is enabled by default when you start a MySQL (or MariaDB) session. You can check the status by calling the function below:
```sql
SELECT @@autocommit;
```
This should return 1 if autocommit is enabled and 0 if is disabled.
As the Isolation Level is set to Repeatable-Read, one an user call this procedure, it will lock the read acess until the transaction is complete. Once it's completed, the DBMS will automatically release the read lock.

## Adding a backup
### Mysqldump
Mysqldump is a command-line utility tool provided by MySQL (and its variants like MariaDB) that we can use to perform logical backups of MySQL databases. It generates SQL statements that can be used to recreate the database's structure (schema) and its data. This tool is particularly useful for creating backups of databases that can be easily restored or migrated to another server.
Docummentation is avaliable ![here](https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html).
```bash
mysqldump -u username -p mydatabase > backup.sql
```
This command will take as arguments the username (-u), password (-p) and database name (mydatabase). In the case above, it will generate a file named backup.sql containing all the SQL statements. Note that if you are using MariaDB, like I am, it is possible that mysqldump is deprecated by the time you are reading this, so use the command mariadb-dump instead.
The backup generated is stored in the backup.sql file in this repository.

## Engines
This section is still in progress.

## Visualizing the data
There was a section dedicated to visualizing the data here. Since the puprose of this repository has changed, this section is no longer here. Instead, a new repository will be created for a dedicated EDA.


