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


