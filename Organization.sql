-- Create needed tables: actual data and query results
CREATE TABLE people (
  id NUMBER(5) PRIMARY KEY,
  name VARCHAR2(30) NOT NULL,
  title VARCHAR2(30) NULL,
  manager NUMBER(5) NULL,
 
  CONSTRAINT fk_people_manager
    FOREIGN KEY (manager)
    REFERENCES people(id)
);

CREATE TABLE results (
  id NUMBER(5) PRIMARY KEY,
  name VARCHAR2(30) NOT NULL,
  title VARCHAR2(30) NULL,
  manager NUMBER(5) NULL
);


-- Procedure for populating people-table with random data.
-- The organization begins with CEO and then hierarchy tree is generated randomly.
CREATE OR REPLACE PROCEDURE generate_people AS
  manager_id NUMBER(5);
BEGIN
  -- Empty the table first
  DELETE FROM people;
 
  -- Insert the boss
  INSERT INTO people(id, name, title, manager) VALUES (0, 'Mr. Big', 'CEO', null);
 
  -- Insert fifty more people under some previously inserted person
  FOR i IN 1..50 LOOP
    SELECT id INTO manager_id FROM (SELECT id FROM people ORDER BY DBMS_RANDOM.VALUE) WHERE ROWNUM = 1;
    INSERT INTO people(id, name, title, manager)
      VALUES (
        i,
        DBMS_RANDOM.STRING('u',10),
        CASE ROUND(DBMS_RANDOM.VALUE(1,2)) WHEN 1 THEN 'Developer' WHEN 2 THEN 'Tester' END,
        manager_id
        );
  END LOOP;
  COMMIT;
END;
/

-- Procedure for copying some certain branch of organization into the result table.
-- If root manager is not given as a parameter, the whole organization is listed.
CREATE OR REPLACE PROCEDURE list_organization (root_manager IN NUMBER DEFAULT 0) AS
BEGIN
  DELETE FROM results;
  INSERT INTO results SELECT * FROM people START WITH id = root_manager CONNECT BY PRIOR id = manager;
  COMMIT;
END;
/

-- Usage:
-- Generate the test data
EXECUTE generate_people;
-- Copy some branch of the organization into results table
EXECUTE list_organization(4);
-- And finally check results
SELECT * FROM results;
