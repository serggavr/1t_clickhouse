## Создание витрины 'promo_effectiveness' в 'Clickhouse'
***

Соединения коннтейнеров `postgres`, `clickhouse` и `click-ui` внутри одной сети. 
Необходимо добавить в `docker-compose.yml` следующие записи:
```dockerfile
#version: "3.8"
#services:
#  postgres:
#    image: postgres:latest
    networks:
      - clickhouse      
    ports:
      - "5434:5432"
#    environment:
#      POSTGRES_USER: postgres
#      POSTGRES_PASSWORD: postgres
#      POSTGRES_DB: testdb
#    volumes:
#      - ./postgres/ddl/init.sql:/docker-entrypoint-initdb.d/init.sql
#      - ./postgres/dml/load_data_scripts.sql:/docker-entrypoint-initdb.d/load_data_scripts.sql      
#    healthcheck:
#      test: ["CMD", "pg_isready", "-U", "postgres"]
#      interval: 5s
#      retries: 5
#    restart: always
#
#  clickhouse:
#    image: clickhouse/clickhouse-server:latest
    networks:
        - clickhouse
    ports:
        - "8123:8123"
#    ulimits:
#        nofile:
#          soft: 262144
#          hard: 262144 
#    volumes:
#      - "clickhouse-data:/var/lib/clickhouse"
#
#  click-ui:
#    image: spoonest/clickhouse-tabix-web-client
    networks:
        - clickhouse
    ports:
        - "8124:80"
#    depends_on:
#      - clickhouse
#    restart: always
#volumes:
#  clickhouse-data:
networks:
    clickhouse:
      driver: bridge
      name: local_network
```

Создание пользователя *clickhouse_user* с паролем *click* в `Postgres`.  
В `postgres/ddl/createuser.sql` необходимо добавить:
```sql
CREATE ROLE clickhouse_user SUPERUSER LOGIN PASSWORD 'click';
```  
Создание сущности *dwh* в `Postgres`.  
В `postgres/ddl/init.sql` необходимо добавить:
```sql
CREATE TABLE IF NOT EXISTS dwh
(
user_lk_id INTEGER PRIMARY KEY,
user_sex VARCHAR(8),
user_bod_category INTEGER,
user_email VARCHAR(128),
user_phone VARCHAR(16),
user_most_purshased_model INTEGER,
user_most_purshased_brend INTEGER,
user_most_purshased_category INTEGER,
promo_item_spend_per_month INTEGER
);
```
Заполнение *dwh* в `Postgres` данными.
В `postgres/dml/load_data_scripts.sql` необходимо добавить:
```sql
INSERT INTO dwh (
     user_lk_id,
     user_sex,
     user_bod_category,
     user_email,
     user_phone,
     user_most_purshased_model,
     user_most_purshased_brend,
     user_most_purshased_category,
     promo_item_spend_per_month)
VALUES (66, 'male', 2, 'test@test.ru', '+79120000000', 1661, 13, 1, 5),
       (65, 'female', 3, 'email@email.com', '+75550000011', 800, 2, 1, 2);
```   
Запуск docker-compose:
```dockerfile
docker-compose up
```  
В интерфейсе Tabix `localhost:8124`  

Создание БД с именем *db_in_ch* в `Clickhouse` для *dwh* из `Postgres``:
```sql
CREATE DATABASE db_in_ch;
```  
Создание сущности *promo_effectiveness* в `Clickhouse` отражающую структуру и типы данных *dwh* из `Postgres`:
```sql
CREATE TABLE db_in_ch.promo_effectiveness
(
    user_lk_id UInt32,
    user_sex String,
    user_bod_category Int32,
    user_email String,
    user_phone String,
    user_most_purshased_model Int32,
    user_most_purshased_brend Int32,
    user_most_purshased_category Int32,
    promo_item_spend_per_month Int32,
)
ENGINE = PostgreSQL('postgres:5432', 'db_in_psg', 'dwh', 'clickhouse_user', 'click');
```  
