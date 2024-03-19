-- Funtion to add position
CREATE OR REPLACE FUNCTION fn_add_position(
	f_position_name varchar(25) ,
	f_job_description varchar(255) DEFAULT NULL
)
RETURNS VARCHAR
LANGUAGE PLPGSQL
AS $$
BEGIN
	IF EXISTS (SELECT 1 FROM positions WHERE position_name = f_position_name) THEN
		RETURN 'Position already exist';
	ELSE
		INSERT INTO positions(position_name, job_description)
		VALUES (f_position_name, f_job_description);
		RETURN 'position added';
	END IF;
END;
$$;


-- FUNCTION to ADD employee
CREATE OR REPLACE FUNCTION fn_add_employee(
	ssn CHAR(14),
	first_name VARCHAR(35),
	last_name VARCHAR(35) ,
	gender sex_type,
	salary INT,
	status employee_status_type DEFAULT 'pending',
	f_position_id INT DEFAULT NULL,
	f_branch_id INT DEFAULT NULL,
	f_section_id INT DEFAULT NULL,
	birthdate DATE DEFAULT NULL,
	address VARCHAR(255) DEFAULT NULL,
	date_hired timestamptz DEFAULT CURRENT_TIMESTAMP
)
RETURNS VARCHAR	
LANGUAGE PLPGSQL
AS $$
DECLARE
	f_employee_id INT;
BEGIN 
	IF EXISTS (SELECT 1 FROM employees WHERE ssn = employee_ssn) THEN
		RETURN 'SSN existed';
	ELSE
		INSERT INTO employees(
			employee_ssn,
			employee_first_name,
			employee_last_name,
			employee_birthdate,
			employee_address,
			employee_date_hired,
			employee_salary,
			employee_status,
			employee_gender
		) VALUES (
			ssn,
			first_name,
			last_name,
			birthdate,
			address,
			date_hired,
			salary,
			status,
			gender
		) RETURNING employee_id INTO f_employee_id;
		
		IF f_branch_id IS NOT NULL AND f_section_id IS NOT NULL  THEN 
			INSERT INTO branches_staff(employee_id, branch_id, section_id)
			VALUES (f_employee_id, f_branch_id, f_section_id);
		END IF;
		
		IF f_position_id IS NOT NULL THEN
			INSERT INTO employees_position(employee_id, position_id)
			VALUES(f_employee_id, f_position_id);
		END IF;
		
		RETURN 'Employee added';
	END IF;
END;
$$;

-- Function to insert data into employees account using id 
-- Called using select -> select fn_insert_employee_account
CREATE OR REPLACE FUNCTION fn_insert_employee_account(
    f_employee_id INT,
    f_email varchar(254),
    f_password varchar(512),
	f_salt varchar(16)
)
RETURNS VARCHAR
LANGUAGE PLPGSQL
AS $$
BEGIN
	IF EXISTS (SELECT 1 FROM employees_accounts WHERE employee_email = f_email) THEN
		RETURN 'Account existed';
	ELSE
		INSERT INTO employees_accounts (
			employee_id,
			employee_email,
			employee_password,
			employee_salt
		) VALUES (
			f_employee_id,
			f_email,
			f_password,
			f_salt
		);
		
		RETURN 'Account added';
	END IF;
END;
$$;

-- FUNCTION to insert data into employees account using ssn
CREATE OR REPLACE FUNCTION fn_insert_employee_account_ssn(
	f_employee_ssn varchar(14),
    f_email varchar(254),
    f_password varchar(512),
	f_salt VARCHAR(16)
)
RETURNS VARCHAR
LANGUAGE PLPGSQL
AS $$
DECLARE 
	f_employee_id INT;
BEGIN
	SELECT employee_id INTO f_employee_id FROM employees WHERE employee_ssn =  f_employee_ssn;
	IF FOUND THEN
		IF EXISTS (SELECT 1 FROM employees_accounts WHERE employee_email = f_email) THEN
			RETURN 'Account existed';
		ELSE
			INSERT INTO employees_accounts (
			employee_id,
			employee_email,
			employee_password,
			employee_salt
			) VALUES (
				f_employee_id,
				f_email,
				f_password,
				f_salt
			);
			RETURN 'Account added';
		END IF;
	ELSE
		RETURN ('Employee with SSN ' || f_employee_ssn ||' not found');
--         RAISE EXCEPTION 'Employee with SSN % not found', f_employee_ssn;
	END IF;
END;
$$;



-- FUNCTION to add new branch
CREATE OR REPLACE FUNCTION fn_add_branch(
	f_branch_name VARCHAR(35),
	f_branch_address VARCHAR(95) ,
	f_location_coordinates POINT ,
	f_coverage SMALLINT DEFAULT 10,
	f_branch_phone VARCHAR(15) DEFAULT NULL,
	f_manager_id INT DEFAULT NULL
)
RETURNS VARCHAR
LANGUAGE PLPGSQL
AS $$
DECLARE
	f_branch_id INT;
BEGIN
	IF NOT EXISTS (SELECT 1 FROM branches WHERE f_branch_name = branch_name) THEN

		INSERT INTO branches(branch_name,branch_address,branch_phone, location_coordinates, coverage)
		VALUES(f_branch_name,f_branch_address,f_branch_phone, f_location_coordinates, f_coverage)
		RETURNING branch_id INTO f_branch_id;
		
		IF f_manager_id IS NOT NULL THEN
			INSERT INTO branches_managers VALUES(f_branch_id, f_manager_id);
		END IF;
		RETURN 'Branch added';
	ELSE
		RETURN 'Branch Existed';
	END IF;
END;
$$;



-- FUNCTION to add new table
CREATE OR REPLACE FUNCTION fn_add_table(
	f_branch_id INT,
	f_capacity INT,
	f_table_status table_status_type DEFAULT 'available'
)
RETURNS VOID
LANGUAGE PLPGSQL
AS $$
BEGIN
	INSERT INTO branch_tables(branch_id,capacity, table_id, table_status)
	VALUES (f_branch_id,
			f_capacity,
			nextval('branch_' || f_branch_id || '_table_id_seq'),
			f_table_status);
END;
$$;

-- FUNCTION to add new general section
CREATE OR REPLACE FUNCTION fn_add_general_section(
	f_section_name VARCHAR(35),
	f_section_description VARCHAR(254)
)
RETURNS VOID
LANGUAGE PLPGSQL
AS $$
BEGIN
	INSERT INTO sections (section_name, section_description)VALUES (f_section_name, f_section_description);
END;
$$;

-- Funtion to add section to branch
CREATE OR REPLACE FUNCTION fn_add_branch_sections(
	fn_branch_id INT,
	fn_section_id INT,
	fn_manager_id INT DEFAULT NULL
)
RETURNS VARCHAR
LANGUAGE PLPGSQL
AS $$
BEGIN
	INSERT INTO branch_sections(branch_id,section_id,manager_id)
	VALUES(fn_branch_id,fn_section_id,fn_manager_id);
	RETURN 'section added to branch';
END;
$$;

-- FUNCTION to add new category 
CREATE OR REPLACE PROCEDURE pr_add_category(
	f_section_id INT,
	f_category_name VARCHAR(35),
	f_category_description VARCHAR(254)
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	INSERT INTO categories (section_id, category_name, category_description)
	VALUES (f_section_id, f_category_name, f_category_description);
END;
$$;

-- Procedure to add new storage 
CREATE OR REPLACE PROCEDURE pr_add_storage(
	pr_storage_name VARCHAR(35),
	pr_storage_address VARCHAR(95),
	pr_manager_id INT DEFAULT NULL
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM 1 FROM storages WHERE storage_name = pr_storage_name;
	IF FOUND THEN
		RETURN;
	ELSE
		INSERT INTO storages (storage_name, storage_address, manager_id)
		VALUES (pr_storage_name, pr_storage_address, pr_manager_id);
	END IF;
END;
$$;

-- Procedure to add new ingredient
CREATE OR REPLACE PROCEDURE pr_add_ingredient(
	pr_ingredients_name VARCHAR(35),
	pr_recipe_ingredients_unit ingredients_unit_type ,
	pr_shipment_ingredients_unit	ingredients_unit_type
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM 1 FROM ingredients WHERE pr_ingredients_name = ingredients_name;
	IF FOUND THEN
		RETURN;
	ELSE
		INSERT INTO ingredients(ingredients_name, recipe_ingredients_unit, shipment_ingredients_unit)
		VALUES (pr_ingredients_name, pr_recipe_ingredients_unit, pr_shipment_ingredients_unit);
	END IF;
END;
$$;
	
-- Procedure to add new ingredient to the branch stock
CREATE OR REPLACE PROCEDURE pr_add_ingredient_to_branch_stock(
	p_branch_id INT,
	p_ingredient_id INT,
	p_ingredients_quantity NUMERIC(12, 3)
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	PERFORM 1 FROM branches_stock WHERE branch_id = p_branch_id AND ingredient_id = p_ingredient_id;
	IF FOUND THEN
		RETURN;
	ELSE
		INSERT INTO branches_stock(branch_id, ingredient_id, ingredients_quantity)
		VALUES (p_branch_id, p_ingredient_id, p_ingredients_quantity);
	END IF;
END;
$$;
