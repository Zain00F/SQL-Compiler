-- COMPREHENSIVE LEXER TEST SUITE
-- Testing all identified issues before moving to parser

-- Test 1: Unicode Strings (N'...' should be ONE token, not N + '...')
-- SELECT N'Unicode String Test' AS unicode_test;
-- SELECT n'lowercase n prefix' AS unicode_lower;
-- INSERT INTO table VALUES (N'Test Value');

-- -- Test 2: Bracketed Identifiers with escaped brackets
-- SELECT [Column Name] FROM [Table Name];
-- SELECT [Column]]With]]Brackets] FROM [Another]]Table];
-- UPDATE [dbo].[DIAGNOSIS] SET [DIAGNOSIS_KEY''1] = 1;

-- Test 3: Single Quote String Greedy Consumption Test
-- This should NOT consume everything until line 28
-- SELECT 'First String' AS test1;
-- SELECT 'Second String' AS test2;
-- INSERT INTO users VALUES ('John''s Data', 'More Data');
-- SELECT 'Third String' AS test3;

-- Test 4: Nested Comments with Newlines
-- SELECT 'before_comment' AS test;
-- /* This is a multi-line comment
--    that spans several lines
--    /* with nested comment inside
--       that also spans lines */
--    back to outer comment */
-- SELECT 'after_comment' AS test;

-- Test 5: Complex Nested Comments
/* Level 1 comment
   SELECT 'hidden code';
   /* Level 2 comment
      UPDATE table SET col = 'value';
      /* Level 3 comment */
      DELETE FROM table;
   */ 
   INSERT INTO table VALUES ('test');
*/ 
-- SELECT 'visible_code' AS test;

-- Test 6: Identifier vs String Ambiguity Test
-- These should be clearly distinguished
-- SELECT [KEY1'S] FROM table1;  -- Bracketed identifier with quote
-- SELECT 'KEY1''S' FROM table2; -- String with escaped quote
-- UPDATE table SET name = 'John''s car';

-- Test 7: Variable Recognition
-- DECLARE @user_var NVARCHAR(50);
-- SET @user_var = 'test value';
-- SELECT @@ROWCOUNT AS system_var;

-- -- Test 8: Compound Operators
-- UPDATE table SET col1 += 5, col2 -= 3;
-- SET @var += 10;

-- Test 9: String Splitting Tests (Backslash + Newline)
-- SELECT 'line1\
-- line2' AS split_string;

-- SELECT B'10101100' AS split_binary;

-- SELECT 0x48656C\
-- 6C6F AS split_hex;

-- -- Test 10: Escaped Quotes in Different Contexts
-- SELECT 'Customer''s "favorite" item' AS mixed_quotes;
-- SELECT "File path: 'C:\Program Files\App'" AS path_string;
-- SELECT N'Unicode with ''escaped'' quotes' AS unicode_escaped;

-- Test 11: Complex Real-World T-SQL
-- IF NOT EXISTS (
--     SELECT 1 FROM sys.columns
--     WHERE Name = 'KEY1''S'
--       AND Object_ID = Object_ID('FACT1')
-- )
-- BEGIN
--     ALTER TABLE FACT1 
--     ADD [KEY1'S] INT NULL;
-- END;

-- Test 12: Comments Mixed with Code
-- SELECT col1, -- line comment
--        col2 /* inline block comment */ ,
--        col3
-- FROM table_name /* another comment */
-- WHERE col1 = 'value'; -- final comment

-- Test 13: Edge Cases
-- SELECT '' AS empty_string;
-- SELECT '''' AS just_quote;
-- SELECT N'' AS empty_unicode;
-- SELECT [] AS empty_bracket; -- This might be invalid but test anyway

-- Test 14: Stress Test - Multiple Issues Combined
DECLARE @sql NVARCHAR(MAX) = N'
    SELECT [Customer''s Name], 
           ''John''''s Data'' AS test,
           /* comment with N''unicode'' inside */ 
           @variable += 10
    FROM [Table]]With]]Brackets]
    WHERE col = ''value''''s''
';

-- Test 15: Binary and Hex with Various Formats
-- SELECT B'1010' AS simple_binary;
SELECT 0b1010 AS unquoted_binary;
-- SELECT X'48656C6C6F' AS hex_string;
SELECT 0x48656C6C6F AS hex_number;
0x23\
222