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

-- Function to change employee position
CREATE OR REPLACE FUNCTION fn_change_employee_position(
	fn_employee_id INT,
	fn_position_changer_id INT,
	fn_new_position INT,
	fn_position_change_type position_change_type
)
RETURNS VARCHAR
LANGUAGE PLPGSQL
AS $$
DECLARE
	fn_previous_position_id INT DEFAULT NULL;
BEGIN
	IF EXISTS(SELECT 1 FROM employees WHERE fn_employee_id = employee_id) THEN
	
		IF fn_position_changer_id IN (SELECT employee_id FROM employees_position WHERE position_id IN (1, 2)) THEN
			SELECT position_id INTO fn_previous_position_id FROM employees_position WHERE fn_employee_id = employee_id;
			UPDATE employees_position
			SET position_id = fn_new_position
			WHERE employee_id = fn_employee_id;
			

			INSERT INTO positions_changes(employee_id, position_changer_id, previous_position, new_position, position_change_type)
			VALUES (fn_employee_id, fn_position_changer_id, fn_previous_position_id, fn_new_position, fn_position_change_type);

			RETURN 'Employee position changed';
		ELSE
			RETURN 'Premission denied';
		END IF;
	ELSE
		RETURN 'Employee not Exist';
	END IF;
END;
$$;
