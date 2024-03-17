CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Function to check customer account
CREATE OR REPLACE FUNCTION fn_check_login_customer(
	f_customer_email varchar(254),
	f_customer_password varchar(512)
)
RETURNS TABLE (
	cust_id INT,
	cust_f_name VARCHAR(35),
	cust_l_name VARCHAR(35)
)
LANGUAGE PLPGSQL
AS $$
DECLARE
	f_customer_id INT;
BEGIN
	SELECT customer_id INTO f_customer_id FROM customers_accounts WHERE customer_email = f_customer_email AND f_customer_password = customer_password;
	IF FOUND THEN
		RETURN QUERY
			SELECT customer_id, customer_first_name, customer_last_name
			FROM customers
			WHERE customer_id = f_customer_id;
	ELSE
		RETURN ;
	END IF;
END;
$$;




-- Function to check employee account
-- **********return position******* didn't added yet  
CREATE OR REPLACE FUNCTION fn_check_login_employee(
	f_employee_email varchar(254),
	f_employee_password varchar(512)
)
RETURNS TABLE (
	emp_id INT,
	emp_f_name VARCHAR(35),
	emp_l_name VARCHAR(35),
	emp_status employee_status_type
)
LANGUAGE PLPGSQL
AS $$
DECLARE
	f_employee_id INT;
BEGIN
	SELECT employee_id INTO f_employee_id FROM employees_accounts WHERE employee_email = f_employee_email AND crypt(f_employee_password, employee_password);
	IF FOUND THEN
		RETURN QUERY
			SELECT employee_id, employee_first_name, employee_last_name, employee_status
			FROM employees
			WHERE employee_id = f_employee_id;
	ELSE
		RETURN ;
	END IF;
END;
$$;
