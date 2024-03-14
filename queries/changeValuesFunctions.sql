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


