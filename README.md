## Создание витрины 'sales' в 'Clickhouse'
***
Запуск docker-compose с Postgres и Clickhouse:
```bash
docker-compose up
```  
***
Устанавливаем Apatch Superset:  
Первым делом генерируем jwt-ключ для подключения к Superset, далее он пригодится:
```bash
openssl rand -base64 42
```
Далее, выполняем команду, в моем случае с JWT `Pt+PgZWMmYqfhlszp497GYDAL+diJ1q8mQmw/zU9wHFOQRfkU1owTOsj`, вы вводите свой ключ:
```bash
docker run -d --net=local_network -p 8080:8088 -e "SUPERSET_SECRET_KEY=Pt+PgZWMmYqfhlszp497GYDAL+diJ1q8mQmw/zU9wHFOQRfkU1owTOsj" --name superset apache/superset
```
В контейнере с Superset, в папке `app/pythonpath/` создаем `superset_config.py`, в файл записываем `SECRET_KEY = 'СГЕНЕРИРОВАННЫЙ_JWT_КЛЮЧ'`   

Создаем учетную запись пользователя в Superset
```bash
docker exec -it superset superset fab create-admin --username admin --firstname Superset --lastname Admin --email admin@superset.com --password admin
```  
Далее, обновляем БД 
```bash
docker exec -it superset superset db upgrade
```
Настраиваем роли:
```bash
docker exec -it superset superset init
```  
Устанавливаем https://github.com/ClickHouse/clickhouse-connect в контейнере с Clickhouse. Рестартуем контейнер с Superset. 
```bash
pip install clickhouse-connect
```

Для соединения Superset с Clickhouse  используем адрес:
```clickhouse
clickhousedb://host.docker.internal/default
```
P.S для соединения Superset с Postgres тоже используем адрес **host.docker.internal** вместо **localhost**
***
 

В интерфейсе Tabix `localhost:8124` или в DBeaver: 


Создание БД *db_in_ch* в `Clickhouse` создание сущностей в `Clickhouse` , соединение с`Postgres`, перенос данных в `Clickhouse` :

```clickhouse
CREATE DATABASE db_in_ch;

-- Переходии в БД db_in_ch

CREATE TABLE IF NOT EXISTS products(
   product_id UInt32,
   product_name String,
   price Float64
) ENGINE = PostgreSQL('postgres:5432', 'db_in_psg', 'products', 'clickhouse_user', 'click');

CREATE TABLE IF NOT EXISTS shops(
   shop_id UInt32,
   shop_name String
) ENGINE = PostgreSQL('postgres:5432', 'db_in_psg', 'shops', 'clickhouse_user', 'click');

CREATE TABLE IF NOT EXISTS plan(
   plan_date Date,
   product_id UInt32,
   plan_cnt Int32,
   shop_name String
) ENGINE = PostgreSQL('postgres:5432', 'db_in_psg', 'plan', 'clickhouse_user', 'click');

CREATE TABLE IF NOT EXISTS shop_dns(
	shop_id UInt32,
   date Date,
   product_id UInt32,
   sales_cnt Int32
) ENGINE = PostgreSQL('postgres:5432', 'db_in_psg', 'shop_dns', 'clickhouse_user', 'click');

CREATE TABLE IF NOT EXISTS shop_mvideo(
	shop_id UInt32,
   date Date,
   product_id UInt32,
   sales_cnt Int32
) ENGINE = PostgreSQL('postgres:5432', 'db_in_psg', 'shop_mvideo', 'clickhouse_user', 'click');

CREATE TABLE IF NOT EXISTS shop_sitilink(
	shop_id UInt32,
   date Date,
   product_id UInt32,
   sales_cnt Int32
) ENGINE = PostgreSQL('postgres:5432', 'db_in_psg', 'shop_sitilink', 'clickhouse_user', 'click');
```  



Создание витрины 'sales' в `Superset` из `Clickhouse`:
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
		products.product_name,
		sum(sales_cnt) as sales_fact,
		sum(plan_cnt) as sales_plan,
		sum(sales_cnt)/sum(plan_cnt) AS seles_fact_plan,
		sum(sales_cnt) * price AS income_fact,
		sum(plan_cnt) * price AS income_plan,
		(sum(sales_cnt) * price) - (sum(plan_cnt) * price) AS income_fact_plan
	from sales
join shops on sales.shop_id = shops.shop_id
join plan on plan.shop_name = shops.shop_name
join products on products.product_id = sales.product_id
GROUP by month, shops.shop_name, products.product_name, products.price
```
