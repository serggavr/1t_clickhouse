## Создание витрины 'sales' в 'Clickhouse'
***
Запуск docker-compose:
```dockerfile
docker-compose up
```  
В интерфейсе Tabix `localhost:8124`  


Создание БД *db_in_ch* в `Clickhouse` создание сущностей в `Clickhouse` , соединение с`Postgres`, перенос данных в `Clickhouse` :

```sql
CREATE DATABASE db_in_ch;

-- Переходии в БД db_in_ch

CREATE TABLE IF NOT EXISTS product(
   product_id UInt32,
   product_name String,
   price Float64,
) ENGINE = PostgreSQL('postgres:5432', 'db_in_psg', 'product', 'clickhouse_user', 'click');

CREATE TABLE IF NOT EXISTS shops(
   shop_id UInt32,
   shop_name String,
) ENGINE = PostgreSQL('postgres:5432', 'db_in_psg', 'shops', 'clickhouse_user', 'click');

CREATE TABLE IF NOT EXISTS plan(
   plan_date Date,
   product_id UInt32,
   plan_cnt Int32,
   shop_name String,
) ENGINE = PostgreSQL('postgres:5432', 'db_in_psg', 'plan', 'clickhouse_user', 'click');

CREATE TABLE IF NOT EXISTS shop_dns(
	shop_id UInt32,
   date Date,
   product_id UInt32,
   sales_cnt Int32,
) ENGINE = PostgreSQL('postgres:5432', 'db_in_psg', 'shop_dns', 'clickhouse_user', 'click');

CREATE TABLE IF NOT EXISTS shop_mvideo(
	shop_id UInt32,
   date Date,
   product_id UInt32,
   sales_cnt Int32,
) ENGINE = PostgreSQL('postgres:5432', 'db_in_psg', 'shop_mvideo', 'clickhouse_user', 'click');

CREATE TABLE IF NOT EXISTS shop_sitilink(
	shop_id UInt32,
   date Date,
   product_id UInt32,
   sales_cnt Int32,
) ENGINE = PostgreSQL('postgres:5432', 'db_in_psg', 'shop_sitilink', 'clickhouse_user', 'click');

```
Создание витрины 'sales' в `Clickhouse`:
```sql
WITH sales AS 
	(SELECT * FROM (
		SELECT * FROM shop_dns 
		union all 
		SELECT * FROM shop_mvideo 
		union all 
		SELECT * FROM shop_sitilink
		)
	)
	select
		toMonth(plan_date) AS month,
		shops.shop_name as shop_name,
		product.product_name,
		sum(sales_cnt) as sales_fact,
		sum(plan_cnt) as sales_plan,
		sum(sales_cnt)/sum(plan_cnt) AS seles_fact_plan,
		sum(sales_cnt) * price AS income_fact,
		sum(plan_cnt) * price AS income_plan,
		(sum(sales_cnt) * price) - (sum(plan_cnt) * price) AS income_fact_plan
	from sales
join shops on sales.shop_id = shops.shop_id
join plan on plan.shop_name = shops.shop_name
join product on product.product_id = sales.product_id
GROUP by month, shops.shop_name, product.product_name, product.price
```
