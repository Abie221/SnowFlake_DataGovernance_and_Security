CREATE OR REPLACE DATABASE GovernanceDB;
USE DATABASE GovernanceDB;
CREATE OR REPLACE SCHEMA AuditDemo;

-- Create Customers table
CREATE OR REPLACE TABLE AuditDemo.Customers (
    Customer_ID INT,
    First_Name VARCHAR,
    Last_Name VARCHAR,
    Email VARCHAR,
    Phone VARCHAR,
    PRIMARY KEY (Customer_ID)
);

-- Create Orders table
CREATE OR REPLACE TABLE AuditDemo.Orders (
    Order_ID INT,
    Order_Date DATE,
    Customer_ID INT,
    Amount DECIMAL(10,2),
    PRIMARY KEY (Order_ID),
    FOREIGN KEY (Customer_ID) REFERENCES AuditDemo.Customers(Customer_ID)
);


-- Insert sample customers
INSERT INTO AuditDemo.Customers (Customer_ID, First_Name, Last_Name, Email, Phone)
VALUES 
  (1, 'Alice', 'Johnson', 'alice.j@example.com', '123-456-7890'),
  (2, 'Bob', 'Smith', 'bob.smith@example.com', '234-567-8901');

-- Insert sample orders
INSERT INTO AuditDemo.Orders (Order_ID, Order_Date, Customer_ID, Amount)
VALUES
  (1001, '2023-03-01', 1, 150.00),
  (1002, '2023-03-05', 2, 200.50);



-- Create a role for administrators who have full control
CREATE OR REPLACE ROLE ADMIN_ROLE; --1

-- Create a role for data stewards who can manage data (read/write) but not administer the account
CREATE OR REPLACE ROLE DATA_STEWARD; --2 

-- Create a role for read-only access (e.g., analysts)
CREATE OR REPLACE ROLE READ_ONLY; --3

----------------

-- Grant full privileges on the database and schema to the ADMIN_ROLE
GRANT ALL PRIVILEGES ON DATABASE GovernanceDB TO ROLE ADMIN_ROLE;
GRANT ALL PRIVILEGES ON SCHEMA GovernanceDB.AuditDemo TO ROLE ADMIN_ROLE;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA GovernanceDB.AuditDemo TO ROLE ADMIN_ROLE;

-- Grant data stewardship privileges (SELECT, INSERT, UPDATE, DELETE) to DATA_STEWARD
GRANT USAGE ON DATABASE GovernanceDB TO ROLE DATA_STEWARD;
GRANT USAGE ON SCHEMA GovernanceDB.AuditDemo TO ROLE DATA_STEWARD;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA GovernanceDB.AuditDemo TO ROLE DATA_STEWARD;

-- Grant read-only privileges to READ_ONLY role
GRANT USAGE ON DATABASE GovernanceDB TO ROLE READ_ONLY;
GRANT USAGE ON SCHEMA GovernanceDB.AuditDemo TO ROLE READ_ONLY;
GRANT SELECT ON ALL TABLES IN SCHEMA GovernanceDB.AuditDemo TO ROLE READ_ONLY;




-- Create a sample user for a data steward
CREATE OR REPLACE USER Abay PASSWORD='YourPassword123' DEFAULT_ROLE=DATA_STEWARD;
GRANT ROLE DATA_STEWARD TO USER Abay;

-- Create a sample user for a read-only analyst
CREATE OR REPLACE USER Milosz PASSWORD='YourPassword123' DEFAULT_ROLE=READ_ONLY;
GRANT ROLE READ_ONLY TO USER Milosz;


-- Protecting sensible data
CREATE OR REPLACE MASKING POLICY mask_email AS (val string) RETURNS string ->
CASE
    WHEN current_role() IN ('ADMIN_ROLE', 'DATA_STEWARD') THEN val
    ELSE '***MASKED***'
END;
ALTER TABLE AuditDemo.Customers
MODIFY COLUMN Email SET MASKING POLICY mask_email;





-- Making queries

SELECT query_id, user_name, query_text, start_time, execution_status
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
ORDER BY start_time DESC
LIMIT 10;

SELECT *
FROM TABLE(INFORMATION_SCHEMA.LOGIN_HISTORY())
ORDER BY EVENT_TIMESTAMP DESC
LIMIT 10;

SHOW GRANTS ON DATABASE GovernanceDB;
SHOW GRANTS ON SCHEMA GovernanceDB.AuditDemo;
SHOW GRANTS ON TABLE AuditDemo.Customers;


-- Sharing
CREATE OR REPLACE SHARE SecureDataShare;

ALTER SHARE "SECUREDATASHARE" ADD TABLE "GOVERNANCEDB"."AUDITDEMO"."CUSTOMERS";

SHOW SHARES;
SHOW TABLES IN SCHEMA GOVERNANCEDB.AUDITDEMO;

GRANT IMPORTED PRIVILEGES ON SHARE SecureDataShare TO ACCOUNT <external_account>; --in case






