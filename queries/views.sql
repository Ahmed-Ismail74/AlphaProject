--General employees information view
CREATE OR REPLACE VIEW vw_employee (
	employee_id,
	employee_name,
	employee_date_hired,
	employee_status,
	employee_branch,
	employee_position
)
AS SELECT employees.employee_id, (employees.employee_first_name || ' ' || employees.employee_last_name) AS employee_name, employees.employee_date_hired, employees.employee_status, br.branch_name, positions.position_name
FROM employees
LEFT JOIN branches_staff bs ON bs.employee_id = employees.employee_id
LEFT JOIN branches br ON br.branch_id = bs.branch_id
LEFT JOIN employees_position e_po ON e_po.employee_id = employees.employee_id
LEFT JOIN positions ON positions.position_id = e_po.position_id
;

--branches details view  
CREATE OR REPLACE VIEW vw_branches (
	branch_id,
	branch_name,
	manager_name,
	branch_phone,
	branch_address
)
AS SELECT br.branch_id, br.branch_name, (employees.employee_first_name || ' ' || employees.employee_last_name) AS manager_name, br.branch_phone, br.branch_address
FROM branches br
LEFT JOIN branches_managers ON br.branch_id = branches_managers.branch_id
LEFT JOIN employees ON branches_managers.manager_id = employees.employee_id;

--categories details view  
CREATE OR REPLACE VIEW vw_categories(
	category_name,
	section_name,
	category_description
)
AS SELECT categories.category_name, sections.section_name, categories.category_description
FROM categories
JOIN sections ON sections.section_id = categories.section_id;




-- View to show recipes information of all menu items 
CREATE OR REPLACE VIEW vw_recipes(
	item_id ,
	item_name ,
	ingredient_name,
	ingredient_unit ,
	quantity ,
	recipe_status 
)
AS SELECT mi.item_id, mi.item_name, ing.ingredients_name, ing.recipe_ingredients_unit, rec.quantity, rec.recipe_status FROM menu_items mi
LEFT JOIN recipes rec ON rec.item_id = mi.item_id 
LEFT JOIN ingredients  ing ON ing.ingredient_id = rec.ingredient_id;












