-- RAW mode with custom element name
SELECT BusinessEntityID, JobTitle FROM HumanResources.Employee FOR XML RAW('EmployeeRecord');

-- AUTO mode with TYPE and XMLSCHEMA
SELECT BusinessEntityID, FirstName FROM Person.Person FOR XML AUTO, TYPE, XMLSCHEMA;

-- PATH mode with an empty element name (no row wrapper)
SELECT Name, ProductNumber FROM Production.Product FOR XML PATH('');

-- PATH mode with ROOT and ELEMENTS (Element-centric XML)
SELECT TOP 5 Name, Color FROM Production.Product FOR XML PATH('Product'), ROOT('Catalog'), ELEMENTS;

-- XSINIL and ABSENT (Requires ELEMENTS)
SELECT Name, Color FROM Production.Product FOR XML PATH, ELEMENTS XSINIL;
SELECT Name, Color FROM Production.Product FOR XML PATH, ELEMENTS ABSENT;

-- BINARY BASE64 and XMLDATA (Deprecated but still in syntax)
SELECT Name, LargePhoto FROM Production.ProductPhoto FOR XML AUTO, BINARY BASE64, XMLDATA;

-- -- ============================================
-- -- PARSER TESTS - Testing currently supported features
-- -- ============================================

-- -- Test 1: Simple SELECT (single column)
-- SELECT name FROM users;

-- -- Test 2: SELECT with multiple columns
-- SELECT id, name, age FROM customers;

-- -- Test 3: SELECT with aliases
-- SELECT name AS customer_name FROM users;
-- SELECT id AS user_id, name AS full_name FROM customers;
-- SELECT name AS "User Name", age AS 'Age' FROM users;

-- -- Test 4: SELECT with table prefix (schema.table.column)
-- SELECT u.id FROM orders;
-- SELECT schema.users.id FROM schema.users;
-- SELECT u.id, u.name FROM orders;

-- -- Test 5: SELECT with table.* (wildcard with table prefix) - NOTE: May need grammar fix
-- -- SELECT u.* FROM orders;
-- -- SELECT schema.table.* FROM schema.table;

-- -- Test 6: SELECT DISTINCT
-- SELECT DISTINCT name FROM users;
-- SELECT DISTINCT id, name FROM customers;

-- -- Test 7: SELECT ALL (explicit)
-- SELECT ALL name FROM users;

-- -- Test 8: WHERE with comparison operators (=, <, >, <=, >=, <>)
-- SELECT name FROM users WHERE age > 25;
-- SELECT id FROM customers WHERE id < 100;  -- Note: SELECT * not yet supported
-- SELECT name FROM orders WHERE price >= 50;
-- SELECT name FROM products WHERE stock <= 10;
-- SELECT name FROM users WHERE age = 25;
-- SELECT name FROM users WHERE status <> 'inactive';

-- -- Test 9: WHERE with logical operators (AND, OR, NOT)
-- SELECT name FROM users WHERE age > 25 AND status = 'active';
-- SELECT name FROM users WHERE age < 18 OR age > 65;
-- SELECT name FROM users WHERE NOT age = 25;
-- SELECT name FROM users WHERE age > 25 AND (status = 'active' OR role = 'admin');

-- -- Test 10: WHERE with IN clause
-- SELECT name FROM users WHERE id IN (1, 2, 3, 4, 5);
-- SELECT name FROM products WHERE category IN ('electronics', 'books', 'clothing');

-- -- Test 11: WHERE with LIKE (single quote string only)
-- SELECT name FROM users WHERE name LIKE 'John%';

-- -- Test 12: WHERE with IS NULL
-- SELECT name FROM users WHERE email IS NULL;

-- -- Test 13: WHERE with arithmetic expressions
-- SELECT name FROM products WHERE price + tax > 100;
-- SELECT name FROM orders WHERE quantity * price >= 1000;
-- SELECT name FROM users WHERE age - 5 > 18;
-- SELECT name FROM products WHERE price / 2 < 50;

-- -- Test 14: WHERE with parentheses (complex expressions)
-- SELECT name FROM users WHERE (age > 25 OR role = 'admin') AND status = 'active';

-- -- Test 15: ORDER BY
-- SELECT name FROM users ORDER BY name;
-- SELECT name FROM users ORDER BY age DESC;
-- SELECT name FROM users ORDER BY name ASC, age DESC;
-- SELECT name FROM users ORDER BY u.id, u.name DESC;

-- -- Test 16: GROUP BY (basic - no aggregate functions yet)
-- SELECT name FROM users GROUP BY name;
-- SELECT category, name FROM products GROUP BY category, name;

-- -- Test 17: HAVING (basic - no aggregate functions yet)
-- SELECT name FROM users GROUP BY name HAVING name = 'John';
-- SELECT category FROM products GROUP BY category HAVING category <> 'electronics';

-- -- Test 18: Combined clauses
-- SELECT DISTINCT name FROM users WHERE age > 25 ORDER BY name;
-- SELECT name FROM users WHERE age > 18 GROUP BY name HAVING name <> 'test' ORDER BY name DESC;

-- -- Test 19: INSERT statements (without column list)
-- INSERT INTO users VALUES (1, 'John', 25);
-- INSERT INTO products VALUES (1, 'Product A', 99.99, 'electronics');

-- -- Test 20: INSERT statements (with column list)
-- INSERT INTO users (id, name, age) VALUES (1, 'John', 25);
-- INSERT INTO products (id, name, price) VALUES (1, 'Product A', 99.99);

-- -- Test 21: UPDATE statements (simple)
-- UPDATE users SET age = 26;
-- UPDATE users SET name = 'John Doe';
-- UPDATE users SET age = 26, name = 'John Doe';

-- -- Test 22: UPDATE with WHERE clause
-- UPDATE users SET age = 26 WHERE id = 1;
-- UPDATE users SET name = 'John', age = 30 WHERE status = 'active';

-- -- Test 23: UPDATE with compound operators (+=, -=)
-- UPDATE users SET age += 1 WHERE id = 5;
-- UPDATE products SET price -= 10 WHERE category = 'electronics';
-- UPDATE users SET score += 10, count -= 1 WHERE id = 1;

-- -- Test 24: UPDATE with expressions
-- UPDATE products SET price = price * 1.1 WHERE category = 'electronics';
-- UPDATE users SET age = age + 1 WHERE id > 100;

-- -- Test 25: DELETE statements
-- DELETE FROM users;
-- DELETE FROM users WHERE age < 18;
-- DELETE FROM orders WHERE status = 'cancelled';
-- DELETE FROM products WHERE stock <= 0 AND price > 100;

-- -- Test 26: Complex DELETE with expressions
-- DELETE FROM users WHERE (age < 18 OR age > 65) AND status = 'inactive';

-- -- ============================================
-- -- CURRENT LIMITATIONS (not yet supported):
-- -- - SELECT * (standalone wildcard)
-- -- - Aggregate functions (COUNT, SUM, AVG, etc.)
-- -- - Table aliases in FROM clause (FROM users u)
-- -- - BETWEEN operator
-- -- - IS NOT NULL
-- -- - LIKE with column references
-- -- ============================================
