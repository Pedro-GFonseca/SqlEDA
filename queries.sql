USE bike_shop;

\ Como são as vendas para cada estado?

SELECT count(o.order_id) as total_orders, s.store_id, s.store_name, s.state  FROM orders as o, stores as s WHERE o.store_id=s.store_id GROUP BY s.store_id;

\ Quais são os cinco produtos mais vendidos?

SELECT p.product_name, COUNT(oi.quantity) as total_sales  FROM order_items as oi, products as p WHERE oi.product_id=p.product_id GROUP BY p.product_name ORDER BY total_sales DESC LIMIT 5;

\ Qual o número médio de vendas?

SELECT AVG(o.order_id) as orders_average FROM orders as o, stores as s WHERE o.store_id=s.store_id;

\ Qual foi a receita de cada loja?

SELECT SUM(oi.list_price * oi.quantity) as revenue, s.store_name  FROM order_items as oi, stores as s, orders as o WHERE oi.order_id =o.order_id AND o.store_id=s.store_id GROUP BY store_name;

\ Qual foi o número máximo e mínimo de pedidos realizados por cliente?

SELECT CONCAT(c.first_name,' ', c.last_name) as full_name, count(o.order_id) AS number_of_purchases FROM orders as o, customers as c WHERE o.customer_id=c.customer_id GROUP BY full_name ORDER BY number_of_purchases DESC LIMIT 5;

\ Só há um cliente com mais de uma compra. Poderiam ser dois clientes com o mesmo nome?

SELECT CONCAT(first_name, ' ', last_name) as full_name, customer_id  from customers WHERE first_name="Justina" AND last_name="Jenkins";

\ Como as vendas dos produtos em que list_price < 1000 se comparam às vendas onde list_price > 1000?

SELECT p.product_name, oi.list_price, count(oi.order_id) as total_orders FROM order_items as oi, products as p WHERE oi.product_id=p.product_id GROUP BY product_name HAVING oi.list_price > 1000 ORDER BY total_orders DESC;
SELECT p.product_name, oi.list_price, count(oi.order_id) as total_orders FROM order_items as oi, products as p WHERE oi.product_id=p.product_id GROUP BY product_name HAVING oi.list_price < 1000 ORDER BY total_orders DESC;

\ Qual é a faixa de preço dos produtos mais populares?

SELECT count(oi.order_id) as total_orders, p.product_name, oi.list_price FROM order_items AS oi, products AS p WHERE oi.product_id=p.product_id GROUP BY product_name ORDER BY total_orders DESC;


