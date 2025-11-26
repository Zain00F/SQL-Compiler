-- Test 1: Simple case - should parse as two SELECT statements
SELECT 'before' AS test1; SELECT 'after' AS test2;

-- Test 2: With simple nested comment between - should still parse as two SELECTs
SELECT 'before' AS test1; /* outer /* inner */ outer */ SELECT 'after' AS test2;

-- Test 3: Nested comment containing SQL that should be ignored
SELECT 'visible' AS test; /* comment with SELECT 'hidden' FROM table; /* nested SELECT 'also_hidden'; */ more comment */ SELECT 'also_visible' AS test2;

-- Test 4: Multi-level nesting test
SELECT 'start' AS test; /* level1 /* level2 /* level3 */ back2 */ back1 */ SELECT 'end' AS test;

-- Test 5: Test that shows incorrect parsing (if nesting fails)
-- If nested comments don't work, this might break:
SELECT 'test' AS col /* outer comment /* inner comment with */ fake end */ SELECT 'should_work' AS col2;

-- Test 6: Line comment mixed with nested block comment
SELECT 'before_line' AS test; -- line comment /* this should not start a block
SELECT 'after_line' AS test;

-- Test 7: Verify that content inside nested comments is truly ignored
SELECT 'real_query' AS test /* fake query: SELECT * FROM /* nested SELECT COUNT(*) FROM users */ nonexistent_table */ ;