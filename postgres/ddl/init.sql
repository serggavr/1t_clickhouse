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
