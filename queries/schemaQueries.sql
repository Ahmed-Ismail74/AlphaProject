-- Delete all Tables
DO $$ 
DECLARE 
    tableName TEXT; 
BEGIN 
    FOR tableName IN SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' LOOP 
        EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(tableName) || ' CASCADE'; 
    END LOOP; 
END $$;


-- Employees Tables
CREATE TABLE IF NOT EXISTS employees(
	employeeID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY ,
	SSN CHAR(14) UNIQUE,
	empFName VARCHAR(35) NOT NULL,
	empLName VARCHAR(35) NOT NULL,
	empBirthDate timestamptz,
	empAddress VARCHAR(255),
	empDateHired timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
	empStatus employee_status_type NOT NULL,
	empGender sex_type NOT NULL,
	empSalary INT NOT NULL CHECK (empSalary > 3000)
);

CREATE TABLE IF NOT EXISTS employeesAccounts(
	employeeID INT REFERENCES employees,
	custEmail varchar(254) NOT NULL,
	custPasswordHash varchar(512) NOT NULL,
	AccountCreatedDate TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (employeeID)
);

CREATE TABLE IF NOT EXISTS salaryChanges(
	salaryChangeID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	employeeID INT REFERENCES employees(employeeID),
	changeMadeBy INT REFERENCES employees(employeeID),
	changeDate TIMESTAMPTZ NOT NULL,
	changeReason varchar(250)
);

CREATE TABLE IF NOT EXISTS employeesTransfers(
	transferID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	employeeID INT REFERENCES employees(employeeID),
	newBranchID INT , -- Foreign key altered after create branch table
	transferMadeBy INT REFERENCES employees(employeeID),
	transferDate TIMESTAMPTZ NOT NULL,
	transferReason varchar(250)
);

CREATE TABLE IF NOT EXISTS employeesCallList(
	phoneID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	employeeID INT REFERENCES employees,
	employeePhone VARCHAR(15) NOT NULL CHECK (employeePhone ~ '^[0-9]+$') 	
);

CREATE TABLE IF NOT EXISTS employeesAddressesList(
	EmployeeAddressID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	employeeID INT REFERENCES employees,
	employeeAddress VARCHAR(95) NOT NULL,
	city varchar(35),
	locationCoordinates point
);

CREATE TABLE IF NOT EXISTS employeeVacations(
	vacationID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	employeeID INT REFERENCES employees,
	vacationStartDate TIMESTAMPTZ NOT NULL,
	vacationEndDate TIMESTAMPTZ NOT NULL,
	vacationReason varchar(255) NOT NULL
);
CREATE TABLE IF NOT EXISTS employeesWorkDays(
	workDayID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	employeeID INT REFERENCES employees,
	shiftStartTime TIMESTAMPTZ,
	shiftEndTime TIMESTAMPTZ NOT NULL
);
CREATE TABLE IF NOT EXISTS  employeesAttendance(
	workDayID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY ,
	employeeID INT REFERENCES employees,
	timeIn TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	timeOut TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS positions(
	positionID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	postionName varchar(25) NOT NULL,
	jobDescription varchar(255)
);
CREATE TABLE IF NOT EXISTS positionsChanges(
	positionChangeID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	employeeID INT REFERENCES employees,
	changedByID INT REFERENCES employees,
	previousPosID INT REFERENCES positions (positionID),
	newPosID INT REFERENCES positions (positionID),
	positionChangeStatues position_change_type NOT NULL,
	positionChangeTime TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


-- Clients Tables
CREATE TABLE IF NOT EXISTS customers(
	customerID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	custFirstName VARCHAR(35) NOT NULL,
	custLastName VARCHAR(35) NOT NULL,
	custGender sex_type
	
);

CREATE TABLE IF NOT EXISTS customersAccounts(
	accountID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	customerID INT REFERENCES customers,
	custEmail varchar(254) NOT NULL,
	custPasswordHash varchar(512) NOT NULL,
	AccountCreatedDate TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS  customersAddressesList(
	addressID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	customerID INT REFERENCES customers,
	custAddress VARCHAR(95) NOT NULL,
	custCity VARCHAR(35),
	locationCoordinates POINT
);
CREATE TABLE IF NOT EXISTS  customersPhonesList(
	customerPhoneID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	customerID INT REFERENCES customers,
	cutomerPhone VARCHAR(15) NOT NULL CHECK (cutomerPhone ~ '^[0-9]+$')	
);

CREATE TABLE IF NOT EXISTS  friendships(
	friendshipID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	accountID INT REFERENCES customersAccounts,
	friendAccountID	INT REFERENCES customersAccounts
);

CREATE TABLE IF NOT EXISTS  friendsRequests(
	friendshipRequestID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	senderAccountID INT REFERENCES customersAccounts,
	receiverAccountID INT REFERENCES customersAccounts,
	requestDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	friendRequestStatus friend_request_type ,
	statusActionTime TIMESTAMP
);




-- Orgnization Tables

CREATE TABLE IF NOT EXISTS  sections(
	sectionID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	sectionName VARCHAR(35) UNIQUE NOT NULL,
	sectionDescription VARCHAR(254)
);

CREATE TABLE IF NOT EXISTS  categories(
	categoryID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	sectionID INT REFERENCES sections,
	categoryName VARCHAR(35) UNIQUE NOT NULL,
	categoryDescription	VARCHAR(254)
);


CREATE TABLE IF NOT EXISTS  branches(
	branchID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	branchAddress VARCHAR(95) NOT NULL,
	managerID INT REFERENCES employees (employeeID)
);

ALTER TABLE employeesTransfers ADD CONSTRAINT  employeestransfers_newbranchid_fkey
FOREIGN KEY (newBranchID) 
REFERENCES branches(branchID);


CREATE TABLE IF NOT EXISTS  storages(
	storageID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	managerID INT REFERENCES employees (employeeID),
	address VARCHAR(95) NOT NULL
);

CREATE TABLE IF NOT EXISTS  seasons(
	seasonID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	seasonName VARCHAR(35),
	seasonDescription VARCHAR(254)

);

CREATE TABLE IF NOT EXISTS  ingredients(
	ingredientID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	ingredientsName VARCHAR(35),
	recipeIngredientsUnit ingredients_unit_type ,
	shipmentIngredientsUnit	ingredients_unit_type
);


CREATE TABLE IF NOT EXISTS  branchSections(
	branchID INT REFERENCES branches,
	sectionID INT REFERENCES sections,
	managerID INT REFERENCES employees (employeeID),
	PRIMARY KEY (branchID, sectionID)
);

CREATE SEQUENCE IF NOT EXISTS table_id_seq;

CREATE TABLE IF NOT EXISTS  branchTables(
	branchID INT REFERENCES branches,
	tableID INT NOT NULL DEFAULT nextval('table_id_seq') UNIQUE,
	tableStatus table_status_type,
	capacity SMALLINT CHECK (capacity >= 0),
	PRIMARY KEY (branchID, tableID)
);

CREATE TABLE IF NOT EXISTS  branchesStock(
	branchID INT REFERENCES branches,
	ingredientID INT REFERENCES ingredients,
	ingredientsQuantity SMALLINT CHECK (ingredientsQuantity >= 0)
);

CREATE TABLE IF NOT EXISTS  menuItems(
	itemID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	itemName VARCHAR(35) NOT NULL UNIQUE,
	categoryID INT REFERENCES categories,
	itemDescription VARCHAR(254) NOT NULL,
	preparationTime INTERVAL 
);

CREATE TABLE IF NOT EXISTS  branchsMenu(
	branchID INT REFERENCES branches,
	itemID INT REFERENCES menuItems,
	itemStatus menu_item_type,
	itemDiscount NUMERIC(4, 2) check (itemDiscount > 0),
	itemPrice NUMERIC(10, 2) check (itemPrice > 0) NOT NULL
);

CREATE TABLE IF NOT EXISTS  itemsCostChanges(
	costChangeID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	branchID INT REFERENCES branches,
	itemID INT REFERENCES menuItems,
	itemCostChangedBy INT REFERENCES employees(employeeID),
	changeType varchar(10) CHECK (changeType IN ('discount','price')),
	newValue NUMERIC(10, 2) CHECK (newValue > 0)
);

CREATE TABLE IF NOT EXISTS  itemsSeasons(
	seasonID INT REFERENCES seasons,
	itemID INT REFERENCES menuItems,
	PRIMARY KEY (seasonID, itemID)
);


CREATE TABLE IF NOT EXISTS  recipes(
	recipeID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	ingredientID INT REFERENCES ingredients,
	itemID INT REFERENCES menuItems,
	quantity smallint NOT NULL,
	recipeStatus recipe_type
	
);

CREATE TABLE IF NOT EXISTS  storagesStock(
	storageID INT REFERENCES storages,
	ingredientID INT REFERENCES ingredients,
	inStockQuantity	smallint NOT NULL,
	PRIMARY KEY(storageID, ingredientID)
);

CREATE TABLE IF NOT EXISTS  branchesStaff(
	employeeID INT REFERENCES employees ,
	branchID INT REFERENCES branches,
	sectionID INT REFERENCES sections,
	positionID INT REFERENCES positions,
	PRIMARY KEY (employeeID, branchID)
);



-- Shipmnets Tables
CREATE TABLE IF NOT EXISTS  suppliers(
	supplierID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	supplierFName VARCHAR(35) NOT NULL,
	supplierLName VARCHAR(35),
	supplierType VARCHAR(10) CHECK (supplierType IN ('male', 'female','company'))
);


CREATE TABLE IF NOT EXISTS  supplyCompaniesEmployees(
	supplyCompEmpID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	companyID INT REFERENCES suppliers (supplierID),
	supplyCompEmpFName VARCHAR(35) NOT NULL,
	supplyCompEmpLName VARCHAR(35),
	supplyCompEmpGender sex_type
	
);

CREATE TABLE IF NOT EXISTS  suppliersCallList(
	supplierPhoneID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	supplierID INT REFERENCES suppliers,
	phoneNumber VARCHAR(15) NOT NULL CHECK (phoneNumber ~ '^[0-9]+$')	
);

CREATE TABLE IF NOT EXISTS  supplierAddressesList(
	supplierAddressID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	supplierIDINT INT REFERENCES suppliers,
	supplierAddress VARCHAR(95) NOT NULL,
	city VARCHAR(35), 
	locationCoordinates	point
);

CREATE TABLE IF NOT EXISTS  stockOrdersDetails(
	stockOrderID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	storageID INT REFERENCES storages,
	ingredientID INT REFERENCES ingredients,
	quantity SMALLINT NOT NULL CHECK (quantity > 0),
	arrivalTime TIMESTAMPTZ,
	ingredientOrderStatus order_status_type
);

CREATE TABLE IF NOT EXISTS  BranchesStockOrders(
	stockOrderID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	branchID INT REFERENCES branches,
	orderedemployeeID INT REFERENCES employees,
	RequestTime TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS  ingredientsSuppliers(
	supplierID INT REFERENCES suppliers,
	ingredientID INT REFERENCES ingredients,
	PRIMARY KEY(supplierID, ingredientID)
);

CREATE TABLE IF NOT EXISTS  ingredientsShipments(
	shipmentID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	orderedemployeeID INT REFERENCES employees,
	storageID INT REFERENCES storages,
	RequestTime	TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS  shipmentsDetails(
	shipmentID INT REFERENCES ingredientsShipments,
	supplierID INT REFERENCES suppliers,
	ingredientID INT REFERENCES ingredients,
	ingredientQuantity SMALLINT CHECK (ingredientQuantity > 0),
	pricePerUnit NUMERIC(10,2),
	arrivalTime TIMESTAMPTZ,
	ingredientShipmentStatus order_status_type
);


-- Orders Tables

CREATE TABLE IF NOT EXISTS  Orders(
	orderID  INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	customerID  INT REFERENCES customers,
	branchID INT REFERENCES branches,
	addressID INT REFERENCES CustomersAddressesList,
	customerPhoneID INT REFERENCES CustomersPhonesList,
	orderDate TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	shipDate TIMESTAMPTZ,
	order_type order_type ,
	orderStaus order_status_type,
	orderTotalPrice NUMERIC(10,2) CHECK (orderTotalPrice > 0),
	orderCustomerDiscount NUMERIC(4,2) CHECK (orderCustomerDiscount > 0),
	orderPaymentMethod payment_method_type
);

CREATE TABLE IF NOT EXISTS  ordersCreditDetails(
	orderID  INT REFERENCES Orders,
	creditCardNumber varchar(16) NOT NULL,
	creditCardExperMonth SMALLINT NOT NULL CHECK (creditCardExperMonth >= 1 AND creditCardExperMonth <= 12),
	creditCardExperDay SMALLINT NOT NULL CHECK (creditCardExperDay >= 1 AND creditCardExperDay <= 31),
	nameOnCard VARCHAR(35) NOT NULL,
	PRIMARY KEY (orderID)
	
);

CREATE TABLE IF NOT EXISTS  VirtualOrdersItems(
	orderID  INT REFERENCES orders,
	customerID  INT REFERENCES customers,
	itemID INT REFERENCES menuItems,
	quantity SMALLINT CHECK (quantity > 0) NOT NULL,
	quotePrice NUMERIC(6,2) CHECK (quotePrice > 0),
	PRIMARY KEY (orderID, customerID, itemID)
);


CREATE TABLE IF NOT EXISTS  offlineOrdersItems(
	orderID  INT REFERENCES orders,
	itemID INT REFERENCES menuItems,
	quantity SMALLINT CHECK (quantity > 0) NOT NULL,
	quotePrice NUMERIC(6,2) CHECK (quotePrice > 0),
	PRIMARY KEY (orderID, itemID)
);

CREATE TABLE IF NOT EXISTS  loungeOrders(
	orderID  INT ,
	tableID INT ,
	FOREIGN KEY (orderID) REFERENCES orders(orderID),
	FOREIGN KEY (tableID) REFERENCES branchTables(tableID),
	PRIMARY KEY (orderID, tableID)
);

CREATE TABLE IF NOT EXISTS  DeliveredOrders(
	orderID  INT REFERENCES orders,
	deliveryemployeeID INT REFERENCES employees(employeeID),
	ArrivalDateByCust timestamptz,
	ArrivalDateByEmp timestamptz,
	PRIMARY KEY (orderID)
);

-- Bookings Tables
CREATE TABLE IF NOT EXISTS  bookings(
	bookingID INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
	customerID INT REFERENCES customers,
	tableID INT ,
	branchID INT ,
	bookingDate TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
	bookingStartTime TIMESTAMPTZ NOT NULL,
	bookingEndTime TIMESTAMPTZ NOT NULL,
	bookingStatus order_status_type,

	FOREIGN KEY (branchID, tableID) REFERENCES branchTables(branchID, tableID)
);

CREATE TABLE IF NOT EXISTS  bookingsOrders(
	bookingID INT REFERENCES bookings, 
	orderID INT REFERENCES orders,
	PRIMARY KEY (bookingID, orderID)
);