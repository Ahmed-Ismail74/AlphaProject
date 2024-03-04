INSERT INTO employees (employee_ssn,employee_first_name,employee_last_name,employee_birthdate,employee_address,employee_status,employee_gender,employee_salary)
VALUES ('4545454545','ahmed','ismail','2000-05-22','15st asdaskjkasnda','pending','m','8000'),('514545454545','saeed','mohsen','1995-03-02','167st ali hassan','active','m','16000');

INSERT INTO branches (branch_name, branch_address,branch_phone, manager_id)
VALUES ('New Cairo','18st sahol asdjowq','0112154215',1);


select * from employees;
select * from employee_vw;

select * from branches;
select * from branches_managers_vw;

drop view employee_vw;
drop view branches_managers_vw;


CREATE VIEW employee_vw (
	employee_id,
	employee_name,
	employee_date_hired,
	employee_status,
	employee_branch,
	employee_position
)
AS SELECT employees.employee_id, (employees.employee_first_name || ' ' || employees.employee_last_name) AS employee_name, employees.employee_date_hired, employees.employee_status, br.branch_name, po.position_name
FROM employees
LEFT JOIN branches_staff bs ON bs.employee_id = employees.employee_id
LEFT JOIN branches br ON br.branch_id = bs.branch_id
LEFT JOIN positions po ON po.position_id = bs.position_id;
--General employees information view



CREATE VIEW branches_managers_vw (
	manager_name,
	branch_name,
	branch_phone
)
AS SELECT (employees.employee_first_name || ' ' || employees.employee_last_name) AS employee_name, br.branch_name, br.branch_phone
FROM employees
INNER JOIN branches br ON br.manager_id = employees.employee_id
--branch managers view