-- PROCEDURE to ADD employee
CREATE OR REPLACE PROCEDURE pr_add_employee(
	ssn CHAR(14),
	first_name VARCHAR(35),
	last_name VARCHAR(35) ,
	gender sex_type,
	salary INT,
	status employee_status_type,
	birthdate DATE DEFAULT NULL,
	address VARCHAR(255) DEFAULT NULL,
	date_hired timestamptz DEFAULT CURRENT_TIMESTAMP
	)
LANGUAGE PLPGSQL
AS
$$
BEGIN 
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
END;
$$;

-- Procedure to insert data into employees account using id 
CREATE OR REPLACE PROCEDURE pr_insert_employee_account(
    p_employee_id INT,
    p_email varchar(254),
    p_password varchar(512)
)
LANGUAGE PLPGSQL
AS $$
BEGIN
    INSERT INTO employees_accounts (
        employee_id,
        employee_email,
        employee_password
    ) VALUES (
        p_employee_id,
        p_email,
        p_password
    );
END;
$$;


-- Procedure to insert data into employees account using ssn
CREATE OR REPLACE PROCEDURE pr_insert_employee_account_ssn(
	p_employee_ssn varchar(14),
    p_email varchar(254),
    p_password varchar(512)
)
LANGUAGE PLPGSQL
AS $$
DECLARE 
	p_employee_id INT;
BEGIN
	SELECT employee_id INTO p_employee_id FROM employees WHERE employee_ssn =  p_employee_ssn;
	IF FOUND THEN
		INSERT INTO employees_accounts (
			employee_id,
			employee_email,
			employee_password
		) VALUES (
			p_employee_id,
			p_email,
			p_password
		);
	ELSE
        RAISE EXCEPTION 'Employee with SSN % not found', p_employee_ssn;
	END IF;
END;
$$;
	
	

-- Procedure to change employee salary
CREATE OR REPLACE PROCEDURE pr_change_salary(
	p_employee_id int,
	p_changer_id int,
	p_new_salary int,
	p_change_reason varchar(255) DEFAULT NULL
)
LANGUAGE PLPGSQL
AS
$$
DECLARE
    p_current_salary INT;
BEGIN
	SELECT employee_salary INTO p_current_salary FROM employees WHERE employee_id =  p_employee_id;
	
	IF FOUND THEN
		IF p_current_salary <> p_new_salary THEN
		
			INSERT INTO salary_changes (employee_id,change_made_by, old_salary,change_reason)
			VALUES (p_employee_id, p_changer_id, p_current_salary, p_change_reason);

			UPDATE employees 
			SET employee_salary = p_new_salary
			WHERE employee_id = p_employee_id;
		
		ELSE 
			RAISE EXCEPTION 'New salary Is same current';
		END IF;
		
	ELSE
        RAISE EXCEPTION 'Employee with id % not found', p_employee_id;
	END IF;
END;
$$;
	
	
	
	
-- Procedure to create customer 
CREATE OR REPLACE PROCEDURE pr_create_customer_account(
    p_first_name VARCHAR(35),
    p_last_name VARCHAR(35),
    p_gender sex_type,
    p_email varchar(254),
    p_password varchar(512),
    p_birthdate DATE DEFAULT NULL
)
LANGUAGE PLPGSQL
AS $$
DECLARE 
    v_customer_id INT;
BEGIN
    INSERT INTO customers (customer_first_name, customer_last_name, customer_gender, customer_birthdate)
    VALUES (p_first_name, p_last_name, p_gender, p_birthdate)
    RETURNING customer_id INTO v_customer_id;

    INSERT INTO customers_accounts (customer_id, customer_email, customer_password)
    VALUES (v_customer_id, p_email, p_password);
    
END;
$$;


CALL pr_add_employee('12312312312123', 'ahmed', 'ismail', 'm', 4000, 'pending');
CALL pr_add_employee('13213213123213', 'khalid', 'mohamed', 'm', 14000, 'pending');

CALL pr_insert_employee_account_ssn('12312312312123','ahmedismail@gmail.com','asdasdasjdaksjdkasaskdjasdkjasd');
CALL pr_change_salary(1, 2, 12000);


CALL pr_create_customer_account('ahmed','ehab', 'm', 'ahmedehab@gmail.com', '2132131231');
CALL pr_create_customer_account('ahmed','saeed', 'm', 'ahmedsaeed@gmail.com', '2132131231','2000-01-02');

SELECT * FROM employees;
SELECT * FROM employees_accounts;
SELECT * FROM salary_changes;

SELECT * FROM customers;
SELECT * FROM customers_accounts;
