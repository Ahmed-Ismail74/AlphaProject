-- FUNCTION to ADD employee
CREATE OR REPLACE FUNCTION fn_add_employee(
	ssn CHAR(14),
	first_name VARCHAR(35),
	last_name VARCHAR(35) ,
	gender sex_type,
	salary INT,
	status employee_status_type DEFAULT 'pending',
	birthdate DATE DEFAULT NULL,
	address VARCHAR(255) DEFAULT NULL,
	date_hired timestamptz DEFAULT CURRENT_TIMESTAMP
)
RETURNS VARCHAR	
LANGUAGE PLPGSQL
AS $$
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
		);
		RETURN 'Employee added';
	END IF;
END;
$$;

-- Function to insert data into employees account using id 
-- Called using select -> select fn_insert_employee_account
CREATE OR REPLACE FUNCTION fn_insert_employee_account(
    f_employee_id INT,
    f_email varchar(254),
    f_password varchar(512)
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
			employee_password
		) VALUES (
			f_employee_id,
			f_email,
			f_password
		);
		
		RETURN 'Account added';
	END IF;
END;
$$;

-- FUNCTION to insert data into employees account using ssn
CREATE OR REPLACE FUNCTION fn_insert_employee_account_ssn(
	f_employee_ssn varchar(14),
    f_email varchar(254),
    f_password varchar(512)
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
				employee_password
			) VALUES (
				f_employee_id,
				f_email,
				f_password
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
	f_branch_phone VARCHAR(15) DEFAULT NULL,
	f_manager_id INT DEFAULT NULL
)
RETURNS VARCHAR
LANGUAGE PLPGSQL
AS $$
DECLARE
	f_branch_id INT;
BEGIN
	IF EXISTS (SELECT 1 FROM branches WHERE f_branch_name = branch_name) THEN

		INSERT INTO branches(branch_name,branch_address,branch_phone)
		VALUES(f_branch_name,f_branch_address,f_branch_phone)
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
	f_table_status table_status_type DEFAULT 'availabe'
)
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




--FUNCTION to add new postion 
CREATE OR REPLACE FUNCTION fn_add_position(
	f_position_name varchar(25) ,
	f_job_description varchar(255) DEFAULT NULL
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	INSERT INTO positions (position_name, job_description) VALUES (f_position_name, f_job_description);
END;
$$


-- FUNCTION to add new general section
CREATE OR REPLACE FUNCTION fn_add_general_section(
	f_section_name VARCHAR(35),
	f_section_description VARCHAR(254)
)
LANGUAGE PLPGSQL
AS $$
BEGIN
	INSERT INTO sections (section_name, section_description)VALUES (f_section_name, f_section_description);
END;
$$

-- Procedre to add new category 
CREATE OR REPLACE FUNCTION fn_add_category(
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
$$
