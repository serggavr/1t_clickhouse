CREATE TABLE IF NOT EXISTS dwh
(
user_lk_id INTEGER,
user_sex VARCHAR(8),
user_bod_category SMALLINT DEFAULT NULL,
user_email VARCHAR(128) DEFAULT NULL,
user_phone VARCHAR(16) DEFAULT NULL,
user_most_purshased_model INTEGER DEFAULT NULL,
user_most_purshased_brend INTEGER DEFAULT NULL,
user_most_purshased_category INTEGER DEFAULT NULL,
promo_item_spend_per_month INTEGER DEFAULT NULL
);