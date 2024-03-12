-- SELECT * FROM pg_indexes where table_name = 'customers';

-- CREATE INDEX idx_text ON customers USING HASH (custfirstname);
-- drop index idx_text;

-- EXPLAIN SELECT * FROM customers WHERE custfirstname LIKE 'a%';

-- Delete all Tables
DO $$ 
DECLARE 
    tableName TEXT; 
BEGIN 
    FOR tableName IN SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' and table_type = 'BASE TABLE' LOOP 
        EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(tableName) || ' CASCADE'; 
    END LOOP;
	
END $$;


-- Employees Tables
CREATE TABLE IF NOT EXISTS employees(
	employee_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY ,
	employee_ssn CHAR(14) UNIQUE NOT NULL,
	employee_first_name VARCHAR(35) NOT NULL,
	employee_last_name VARCHAR(35) NOT NULL,
	employee_birthdate DATE,
	employee_address VARCHAR(255),
	employee_date_hired timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
	employee_status employee_status_type NOT NULL,
	employee_gender sex_type NOT NULL,
	employee_salary INT NOT NULL CHECK (employee_salary > 3000)
);
CREATE TABLE IF NOT EXISTS employees_accounts(
	employee_id INT REFERENCES employees ON DELETE RESTRICT ON UPDATE CASCADE,
	employee_email varchar(254) NOT NULL UNIQUE,
	employee_password varchar(512) NOT NULL,
	account_created_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (employee_id)
);

CREATE TABLE IF NOT EXISTS salary_changes(
	salary_change_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	employee_id INT REFERENCES employees(employee_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	change_made_by INT REFERENCES employees(employee_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	change_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	old_salary int NOT NULL CHECK (old_salary > 3000),
	change_reason varchar(250)
);

CREATE TABLE IF NOT EXISTS employees_transfers(
	transfer_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	employee_id INT REFERENCES employees(employee_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	newbranch_id INT , -- Foreign key altered after create branch table
	transfer_made_by INT REFERENCES employees(employee_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	transfer_date TIMESTAMPTZ NOT NULL,
	transfer_reason varchar(250)
);

CREATE TABLE IF NOT EXISTS employees_call_list(
	employees_phone_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	employee_id INT REFERENCES employees ON DELETE RESTRICT ON UPDATE CASCADE,
	employees_phone VARCHAR(15) NOT NULL CHECK (employees_phone ~ '^[0-9]+$') 	
);


-- CREATE TABLE IF NOT EXISTS employees_addresses_list(
-- 	employee_address_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
-- 	employee_id INT REFERENCES employees ON DELETE RESTRICT ON UPDATE CASCADE,
-- 	employees_address VARCHAR(95) NOT NULL,
-- 	city varchar(35),
-- 	location_coordinates point
-- );

CREATE TABLE IF NOT EXISTS employee_vacations(
	vacation_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	employee_id INT REFERENCES employees ON DELETE RESTRICT ON UPDATE CASCADE,
	vacation_start_date TIMESTAMPTZ NOT NULL,
	vacation_end_date TIMESTAMPTZ NOT NULL,
	vacation_reason varchar(255) NOT NULL
);
CREATE TABLE IF NOT EXISTS employee_work_days(
	work_day_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	employee_id INT REFERENCES employees ON DELETE RESTRICT ON UPDATE CASCADE,
	shift_start_time TIMESTAMPTZ,
	shift_end_time TIMESTAMPTZ NOT NULL
);
CREATE TABLE IF NOT EXISTS  employee_attendance(
	work_day_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY ,
	employee_id INT REFERENCES employees ON DELETE RESTRICT ON UPDATE CASCADE,
	date_in TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	date_out TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS positions(
	position_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	position_name varchar(25) NOT NULL,
	job_description varchar(255)
);
CREATE TABLE IF NOT EXISTS positions_changes(
	position_change_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	employee_id INT REFERENCES employees ON DELETE RESTRICT ON UPDATE CASCADE,
	position_changer_id INT REFERENCES employees ON DELETE RESTRICT ON UPDATE CASCADE,
	previous_position INT REFERENCES positions (position_id),
	new_position INT REFERENCES positions (position_id),
	position_change_type position_change_type NOT NULL,
	position_change_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


-- Clients Tables
CREATE TABLE IF NOT EXISTS customers(
	customer_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	customer_first_name VARCHAR(35) NOT NULL,
	customer_last_name VARCHAR(35) NOT NULL,
	customer_gender sex_type NOT NULL,
	customer_birthdate DATE
);

CREATE TABLE IF NOT EXISTS customers_accounts(
	account_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	customer_id INT REFERENCES customers ON DELETE RESTRICT ON UPDATE CASCADE,
	customer_email varchar(254) NOT NULL UNIQUE,
	customer_password varchar(512) NOT NULL,
	account_created_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS  customers_addresses_list(
	address_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	customer_id INT REFERENCES customers ON DELETE RESTRICT ON UPDATE CASCADE,
	customer_address VARCHAR(95) NOT NULL,
	customer_city VARCHAR(35),
	location_coordinates POINT
);
CREATE TABLE IF NOT EXISTS  customers_phones_list(
	customer_phone_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	customer_id INT REFERENCES customers ON DELETE RESTRICT ON UPDATE CASCADE,
	customer_phone VARCHAR(15) NOT NULL CHECK (customer_phone ~ '^[0-9]+$')	
);

CREATE TABLE IF NOT EXISTS  friendships(
	friendship_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	account_id INT REFERENCES customers_accounts(account_id),
	friend_account_id	INT REFERENCES customers_accounts(account_id)
);

CREATE TABLE IF NOT EXISTS  friends_requests(
	friendship_request_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	sender_account_id INT REFERENCES customers_accounts (account_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	receiver_account_id INT REFERENCES customers_accounts (account_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	request_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	friend_request_status friend_request_type ,
	request_reply_time TIMESTAMP
);



-- Orgnization Tables

CREATE TABLE IF NOT EXISTS  sections(
	section_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	section_name VARCHAR(35) UNIQUE NOT NULL,
	section_description VARCHAR(254)
);

CREATE TABLE IF NOT EXISTS  categories(
	category_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	section_id INT REFERENCES sections ON DELETE RESTRICT ON UPDATE CASCADE,
	category_name VARCHAR(35) UNIQUE NOT NULL,
	category_description	VARCHAR(254)
);


CREATE TABLE IF NOT EXISTS  branches(
	branch_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	branch_name VARCHAR(35) UNIQUE NOT NULL,
	branch_address VARCHAR(95) NOT NULL,
	branch_phone VARCHAR(15) NOT NULL CHECK (branch_phone  ~ '^[0-9]+$'),
	manager_id INT REFERENCES employees (employee_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

ALTER TABLE employees_transfers ADD CONSTRAINT  employees_transfers_newbranch_id_fkey
FOREIGN KEY (newbranch_id) 
REFERENCES branches(branch_id) ON DELETE RESTRICT ON UPDATE CASCADE;


CREATE TABLE IF NOT EXISTS  storages(
	storage_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	manager_id INT REFERENCES employees (employee_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	storage_address VARCHAR(95) NOT NULL
);

CREATE TABLE IF NOT EXISTS  seasons(
	season_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	season_name VARCHAR(35),
	season_description VARCHAR(254)

);

CREATE TABLE IF NOT EXISTS  ingredients(
	ingredient_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	ingredients_name VARCHAR(35),
	recipe_ingredients_unit ingredients_unit_type ,
	shipment_ingredients_unit	ingredients_unit_type
);


CREATE TABLE IF NOT EXISTS  branch_sections(
	branch_id INT REFERENCES branches,
	section_id INT REFERENCES sections,
	manager_id INT REFERENCES employees (employee_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	PRIMARY KEY (branch_id, section_id)
);
-- create Index

CREATE SEQUENCE IF NOT EXISTS table_id_seq;

CREATE TABLE IF NOT EXISTS  branch_tables(
	branch_id INT REFERENCES branches ON DELETE RESTRICT ON UPDATE CASCADE,
	table_id INT NOT NULL DEFAULT nextval('table_id_seq') UNIQUE,
	table_status table_status_type,
	capacity SMALLINT CHECK (capacity >= 0),
	PRIMARY KEY (branch_id, table_id)
);
-- create Index

CREATE TABLE IF NOT EXISTS  branches_stock(
	branch_id INT REFERENCES branches ON DELETE RESTRICT ON UPDATE CASCADE,
	ingredient_id INT REFERENCES ingredients ON DELETE RESTRICT ON UPDATE CASCADE,
	ingredients_quantity SMALLINT CHECK (ingredients_quantity >= 0)
);

CREATE TABLE IF NOT EXISTS  menu_items(
	item_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	item_name VARCHAR(35) NOT NULL UNIQUE,
	category_id INT REFERENCES categories ON DELETE RESTRICT ON UPDATE CASCADE,
	item_description VARCHAR(254) NOT NULL,
	preparation_time INTERVAL 
);

CREATE TABLE IF NOT EXISTS  branchs_menu(
	branch_id INT REFERENCES branches ON DELETE RESTRICT ON UPDATE CASCADE,
	item_id INT REFERENCES menu_items ON DELETE RESTRICT ON UPDATE CASCADE,
	item_status menu_item_type,
	item_discount NUMERIC(4, 2) check (item_discount > 0),
	item_price NUMERIC(10, 2) check (item_price > 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS  items_price_changes(
	cost_change_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	branch_id INT REFERENCES branches ON DELETE RESTRICT ON UPDATE CASCADE,
	item_id INT REFERENCES menu_items ON DELETE RESTRICT ON UPDATE CASCADE,
	item_cost_changed_by INT REFERENCES employees(employee_id),
	change_type varchar(10) CHECK (change_type IN ('discount','price')),
	new_value NUMERIC(10, 2) CHECK (new_value > 0)
);

CREATE TABLE IF NOT EXISTS  items_seasons(
	season_id INT REFERENCES seasons ON DELETE RESTRICT ON UPDATE CASCADE,
	item_id INT REFERENCES menu_items ON DELETE RESTRICT ON UPDATE CASCADE,
	PRIMARY KEY (season_id, item_id)
);

-- create Index

CREATE TABLE IF NOT EXISTS  recipes(
	recipe_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	ingredient_id INT REFERENCES ingredients ON DELETE RESTRICT ON UPDATE CASCADE,
	item_id INT REFERENCES menu_items ON DELETE RESTRICT ON UPDATE CASCADE,
	quantity smallint NOT NULL,
	recipe_status recipe_type
	
);

CREATE TABLE IF NOT EXISTS  storages_stock(
	storage_id INT REFERENCES storages ON DELETE RESTRICT ON UPDATE CASCADE,
	ingredient_id INT REFERENCES ingredients ON DELETE RESTRICT ON UPDATE CASCADE,
	in_stock_quantity	smallint NOT NULL,
	primary key (storage_id, ingredient_id)
);

CREATE TABLE IF NOT EXISTS  branches_staff(
	employee_id INT REFERENCES employees ON DELETE RESTRICT ON UPDATE CASCADE,
	branch_id INT REFERENCES branches ON DELETE RESTRICT ON UPDATE CASCADE,
	section_id INT REFERENCES sections ON DELETE RESTRICT ON UPDATE CASCADE,
	position_id INT REFERENCES positions ON DELETE RESTRICT ON UPDATE CASCADE,
	PRIMARY KEY (employee_id, branch_id)
);

-- create Index

-- Shipmnets Tables
CREATE TABLE IF NOT EXISTS  suppliers(
	supplier_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	supplier_first_name VARCHAR(35) NOT NULL,
	supplier_last_name VARCHAR(35),
	supplier_type VARCHAR(10) CHECK (supplier_type IN ('male', 'female','company'))
);


CREATE TABLE IF NOT EXISTS  supply_companies_employees(
	supply_empolyee_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	supply_company_id INT REFERENCES suppliers (supplier_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	supply_emp_first_name VARCHAR(35) NOT NULL,
	supply_emp_last_name VARCHAR(35),
	supply_emp_gender sex_type
	
);

CREATE TABLE IF NOT EXISTS  suppliers_call_list(
	supplier_phone_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	supplier_id INT REFERENCES suppliers ON DELETE RESTRICT ON UPDATE CASCADE,
	supplier_phone_number VARCHAR(15) NOT NULL CHECK (supplier_phone_number ~ '^[0-9]+$')	
);

CREATE TABLE IF NOT EXISTS  supplier_addresses_list(
	supplieraddress_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	supplier_id INT REFERENCES suppliers ON DELETE RESTRICT ON UPDATE CASCADE,
	supplier_address VARCHAR(95) NOT NULL,
	city VARCHAR(35), 
	location_coordinates	point
);

CREATE TABLE IF NOT EXISTS  stock_orders_details(
	stockorder_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	storage_id INT REFERENCES storages ON DELETE RESTRICT ON UPDATE CASCADE,
	ingredient_id INT REFERENCES ingredients ON DELETE RESTRICT ON UPDATE CASCADE,
	quantity SMALLINT NOT NULL CHECK (quantity > 0),
	arrival_time TIMESTAMPTZ,
	ingredient_order_status order_status_type
);

CREATE TABLE IF NOT EXISTS  branches_stock_orders(
	stockorder_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	branch_id INT REFERENCES branches ON DELETE RESTRICT ON UPDATE CASCADE,
	ordered_employee_id INT REFERENCES employees(employee_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	request_time TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS  ingredients_suppliers(
	supplier_id INT REFERENCES suppliers ON DELETE RESTRICT ON UPDATE CASCADE,
	ingredient_id INT REFERENCES ingredients ON DELETE RESTRICT ON UPDATE CASCADE,
	primary key (supplier_id, ingredient_id)
);

-- create Index
CREATE TABLE IF NOT EXISTS  ingredients_shipments(
	shipment_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	ordered_employee_id INT REFERENCES employees ON DELETE RESTRICT ON UPDATE CASCADE,
	storage_id INT REFERENCES storages ON DELETE RESTRICT ON UPDATE CASCADE,
	request_time TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS  shipments_details(
	shipment_id INT REFERENCES ingredients_shipments ON DELETE RESTRICT ON UPDATE CASCADE,
	supplier_id INT REFERENCES suppliers ON DELETE RESTRICT ON UPDATE CASCADE,
	ingredient_id INT REFERENCES ingredients ON DELETE RESTRICT ON UPDATE CASCADE,
	ingredient_quantity SMALLINT CHECK (ingredient_quantity > 0),
	price_per_unit NUMERIC(10,2),
	arrival_time TIMESTAMPTZ,
	ingredient_shipment_status order_status_type
);


-- orders Tables

CREATE TABLE IF NOT EXISTS  orders(
	order_id  INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	customer_id  INT REFERENCES customers ON DELETE RESTRICT ON UPDATE CASCADE,
	branch_id INT REFERENCES branches ON DELETE RESTRICT ON UPDATE CASCADE,
	address_id INT REFERENCES customers_addresses_list ON DELETE RESTRICT ON UPDATE CASCADE,
	customer_phone_id INT REFERENCES customers_phones_list ON DELETE RESTRICT ON UPDATE CASCADE,
	order_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	ship_date TIMESTAMPTZ,
	order_type order_type ,
	order_staus order_status_type,
	order_total_price NUMERIC(10,2) CHECK (order_total_price > 0),
	order_customer_discount NUMERIC(4,2) CHECK (order_customer_discount > 0),
	order_payment_method payment_method_type
);

CREATE TABLE IF NOT EXISTS  orders_credit_details(
	order_id  INT REFERENCES orders ON DELETE RESTRICT ON UPDATE CASCADE,
	credit_card_number varchar(16) NOT NULL,
	credit_card_exper_month SMALLINT NOT NULL CHECK (credit_card_exper_month >= 1 AND credit_card_exper_month <= 12),
	credit_card_exper_day SMALLINT NOT NULL CHECK (credit_card_exper_day >= 1 AND credit_card_exper_day <= 31),
	name_on_card VARCHAR(35) NOT NULL,
	PRIMARY KEY (order_id)
	
);

CREATE TABLE IF NOT EXISTS  virtual_orders_items(
	order_id  INT REFERENCES orders ON DELETE RESTRICT ON UPDATE CASCADE,
	customer_id  INT REFERENCES customers ON DELETE RESTRICT ON UPDATE CASCADE,
	item_id INT REFERENCES menu_items ON DELETE RESTRICT ON UPDATE CASCADE,
	quantity SMALLINT CHECK (quantity > 0) NOT NULL,
	quote_price NUMERIC(6,2) CHECK (quote_price > 0),
	PRIMARY KEY (order_id, customer_id, item_id)
);

-- create Index

CREATE TABLE IF NOT EXISTS  offline_orders_items(
	order_id  INT REFERENCES orders ON DELETE RESTRICT ON UPDATE CASCADE,
	item_id INT REFERENCES menu_items ON DELETE RESTRICT ON UPDATE CASCADE,
	quantity SMALLINT CHECK (quantity > 0) NOT NULL,
	quote_price NUMERIC(6,2) CHECK (quote_price > 0),
	PRIMARY KEY (order_id, item_id)
);
-- create Index

CREATE TABLE IF NOT EXISTS  lounge_orders(
	order_id  INT ,
	table_id INT ,
	FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (table_id) REFERENCES branch_tables(table_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	PRIMARY KEY (order_id, table_id)
);

-- create Index
CREATE TABLE IF NOT EXISTS  delivered_orders(
	order_id  INT REFERENCES orders,
	delivery_employee_id INT REFERENCES employees(employee_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	arrival_date_by_customer timestamptz,
	arrival_date_by_employee timestamptz,
	PRIMARY KEY (order_id)
);

-- Bookings Tables
CREATE TABLE IF NOT EXISTS  bookings(
	booking_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	customer_id INT REFERENCES customers ON DELETE RESTRICT ON UPDATE CASCADE,
	table_id INT ,
	branch_id INT ,
	booking_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
	booking_start_time TIMESTAMPTZ NOT NULL,
	booking_end_time TIMESTAMPTZ NOT NULL,
	booking_status order_status_type,

	FOREIGN KEY (branch_id, table_id) REFERENCES branch_tables(branch_id, table_id)
);

CREATE TABLE IF NOT EXISTS  bookings_orders(
	booking_id INT REFERENCES bookings ON DELETE RESTRICT ON UPDATE CASCADE, 
	order_id INT REFERENCES orders ON DELETE RESTRICT ON UPDATE CASCADE,
	PRIMARY KEY (booking_id, order_id)
);
-- create Index