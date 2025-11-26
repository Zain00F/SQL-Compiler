-- -- Test 1: Escaped single quotes (double single quotes should become single quote)
-- SELECT 'John''s car' AS escaped_single_quote;
-- SELECT 'It''s a beautiful day' AS another_escaped_quote;
-- SELECT 'She said ''Hello'' to me' AS nested_escaped_quotes;

-- -- Test 2: Mixed single and double quotes in strings
-- SELECT "John's car" AS double_quoted_string;
-- SELECT 'He said "Hello" to me' AS single_quoted_with_double_inside;
-- SELECT "She said ""Hi"" loudly" AS escaped_double_quotes;

-- -- Test 3: String splitting with backslash (should replace \ with space)
-- SELECT 'abc\def' AS backslash_string;
-- SELECT 'path\to\file' AS multiple_backslashes;
-- SELECT 'line1\line2\line3' AS backslash_lines;

-- -- Test 4: String splitting with newline breaks (should replace newline with space)
-- SELECT 'first line
-- second line' AS multiline_string;
-- SELECT 'hello
-- world
-- test' AS three_line_string;

-- -- Test 5: Combined backslash and newline cases
-- SELECT 'abc\def
-- ghi\jkl' AS mixed_backslash_newline;

-- -- Test 6: Hexadecimal string tests
-- SELECT X'48656C6C6F' AS hex_hello;
-- SELECT 0x48656C6C6F AS hex_binary;

-- -- Test 7: Binary/Bit string tests (using B'...' with 0s and 1s only)
-- SELECT B'1010' AS binary_simple;
-- SELECT B'11110000' AS binary_byte;
-- SELECT B'101010101010' AS binary_longer;

-- Test 8: Binary string splitting cases (backslash should become space)
-- SELECT B'1010\1100' AS binary_with_backslash;
SELECT B'1010\
1100' AS binary_with_newline;

-- -- Test 9: Hex string splitting cases
-- SELECT X'48656C\6C6F' AS hex_with_backslash;
-- SELECT X'48656C
-- 6C6F' AS hex_with_newline;

-- -- Test 10: Complex escaped quote scenarios
-- SELECT 'Customer''s "favorite" item costs $29.99' AS complex_mixed_quotes;
-- SELECT "The file is located at 'C:\Program Files\App'" AS path_with_quotes;

-- -- Test 11: Edge cases with empty and special strings
-- SELECT '' AS empty_string;
-- SELECT '''' AS just_escaped_quote;
-- SELECT '\' AS just_backslash;
-- SELECT '
-- ' AS just_newline;