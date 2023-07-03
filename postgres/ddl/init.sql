CREATE TABLE IF NOT EXISTS products(
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(100),
    price DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS plan(
    plan_date DATE,
    product_id INTEGER,
    plan_cnt INTEGER,
    shop_name VARCHAR(100),
    PRIMARY KEY (plan_date, product_id, shop_name),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS shops(
    shop_id INTEGER,
    shop_name VARCHAR(100),
    PRIMARY KEY (shop_id)
);

CREATE TABLE IF NOT EXISTS shop_dns(
    shop_id INTEGER,
    date DATE,
    product_id INTEGER,
    sales_cnt INTEGER,
    PRIMARY KEY (date, product_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE SET NULL,
    FOREIGN KEY (shop_id) REFERENCES shops(shop_id)  ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS shop_mvideo(
    shop_id INTEGER,
    date DATE,
    product_id INTEGER,
    sales_cnt INTEGER,
    PRIMARY KEY (date, product_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE SET NULL,
    FOREIGN KEY (shop_id) REFERENCES shops(shop_id)  ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS shop_sitilink(
    shop_id INTEGER,
    date DATE,
    product_id INTEGER,
    sales_cnt INTEGER,
    PRIMARY KEY (date, product_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE SET NULL,
    FOREIGN KEY (shop_id) REFERENCES shops(shop_id)  ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS promo(
    id_promo INTEGER,
    product_id INTEGER,
    shop_name VARCHAR(100),
    discount DOUBLE PRECISION,
    promo_date date,
    PRIMARY KEY (id_promo),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE SET NULL
);

