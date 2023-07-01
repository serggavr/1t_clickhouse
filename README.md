## Создание витрины 'promo_effectiveness'   
***
Запуск docker-compose:
```dockerfile
docker-compose up
```  


Переходим в интерфейс Tabix `localhost:8124`  


Создание соединения с Postgres:
```clickhouse
CREATE DATABASE IF NOT EXISTS postgres
ENGINE = PostgreSQL('127.0.0.1:5432', 'testdb', 'postgres', 'postgres');
```  
Создание БД для DWH:
```clickhouse
CREATE DATABASE IF NOT EXISTS dwh
ENGINE = PostgreSQL('127.0.0.1:5432', 'testdb', 'postgres', 'postgres');
```  
Инициализация promo_effectiveness в DWH:

```clickhouse
CREATE DATABASE IF NOT EXISTS testdb
ENGINE = PostgreSQL('http://127.0.0.1:5434', 'testdb', 'postgres', 'postgres');

CREATE TABLE IF NOT EXISTS dwh.promo_effectiveness
(
user_lk_id UInt32 DEFAULT NULL,
user_sex FixedString(8) DEFAULT NULL,
user_bod_category UInt8 DEFAULT NULL,
user_email FixedString(128) DEFAULT NULL,
user_phone FixedString(16) DEFAULT NULL,
user_most_purshased_model UInt32 DEFAULT NULL,
user_most_purshased_brend UInt32 DEFAULT NULL,
user_most_purshased_category UInt32 DEFAULT NULL,
promo_item_spend_per_month UInt32 DEFAULT NULL,
) ENGINE = MergeTree()
PRIMARY KEY user_lk_id
ORDER BY user_lk_id
SETTINGS allow_nullable_key=1;
```