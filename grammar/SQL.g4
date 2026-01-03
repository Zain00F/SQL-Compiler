lexer grammar SQL;

// 1. Specific Bracketed Identifiers (Highest Priority)
BRACKET_IDENTIFIER: '[' ( ~']'  | ']]')* ']'
    {
        text = self.text[1:-1].replace("]]", "]")
        self.text = text
    };

// 2. Unicode Strings (Must be ABOVE Identifier so 'N' isn't stolen)
UNICODE_STRING: [nN] '\'' ( ~'\'' | '\'\'')* '\'' 
    {
        text = self.text[2:-1].replace("''", "'")
        self.text = text
    };

// 3. Compound Operators (Must be ABOVE PLUS/EQUALS)
ASSIGN_ADD: '+=';
ASSIGN_MIN: '-=';

// 4. Standard Strings
SINGLE_QUOTE_STRING: '\'' (~'\'' | '\'\'')* '\''
    {
        text = self.text[1:-1].replace("''", "'")
        self.text = text
    };

// 5. Reserved Keywords (ADD, SELECT, etc. go here...)
ADD: 'ADD';
ALL: 'ALL';
ALTER: 'ALTER';
AND: 'AND';
ANY: 'ANY';
AS: 'AS';
ASC: 'ASC';
AUTHORIZATION: 'AUTHORIZATION';
BACKUP: 'BACKUP';
BEGIN: 'BEGIN';
BETWEEN: 'BETWEEN';
BREAK: 'BREAK';
BROWSE: 'BROWSE';
BULK: 'BULK';
BY: 'BY';
CASCADE: 'CASCADE';
CASE: 'CASE';
CHECK: 'CHECK';
CHECKPOINT: 'CHECKPOINT';
CLOSE: 'CLOSE';
CLUSTERED: 'CLUSTERED';
COALESCE: 'COALESCE';
COLLATE: 'COLLATE';
COLUMN: 'COLUMN';
COMMIT: 'COMMIT';
COMPUTE: 'COMPUTE';
CONSTRAINT: 'CONSTRAINT';
CONTAINS: 'CONTAINS';
CONTAINSTABLE: 'CONTAINSTABLE';
CONTINUE: 'CONTINUE';
CONVERT: 'CONVERT';
CREATE: 'CREATE';
CROSS: 'CROSS';
CURRENT: 'CURRENT';
CURRENT_DATE: 'CURRENT_DATE';
CURRENT_TIME: 'CURRENT_TIME';
CURRENT_TIMESTAMP: 'CURRENT_TIMESTAMP';
CURRENT_USER: 'CURRENT_USER';
CURSOR: 'CURSOR';
DATABASE: 'DATABASE';
DBCC: 'DBCC';
DEALLOCATE: 'DEALLOCATE';
DECLARE: 'DECLARE';
DEFAULT: 'DEFAULT';
DELETE: 'DELETE';
DENY: 'DENY';
DESC: 'DESC';
DISK: 'DISK';
DISTINCT: 'DISTINCT';
DISTRIBUTED: 'DISTRIBUTED';
DOUBLE: 'DOUBLE';
DROP: 'DROP';
DUMP: 'DUMP';
ELSE: 'ELSE';
END: 'END';
ERRLVL: 'ERRLVL';
ESCAPE: 'ESCAPE';
EXCEPT: 'EXCEPT';
EXEC: 'EXEC';
EXECUTE: 'EXECUTE';
EXISTS: 'EXISTS';
EXIT: 'EXIT';
EXTERNAL: 'EXTERNAL';
FETCH: 'FETCH';
FILE: 'FILE';
FILLFACTOR: 'FILLFACTOR';
FOR: 'FOR';
FOREIGN: 'FOREIGN';
FREETEXT: 'FREETEXT';
FREETEXTTABLE: 'FREETEXTTABLE';
FROM: 'FROM';
FALSE: 'FALSE';
FULL: 'FULL';
FUNCTION: 'FUNCTION';
GOTO: 'GOTO';
GO: 'GO';
GRANT: 'GRANT';
GROUP: 'GROUP';
HAVING: 'HAVING';
HOLDLOCK: 'HOLDLOCK';
IDENTITY: 'IDENTITY';
IDENTITYCOL: 'IDENTITYCOL';
IDENTITY_INSERT: 'IDENTITY_INSERT';
IF: 'IF';
IN: 'IN';
INDEX: 'INDEX';
INNER: 'INNER';
INSERT: 'INSERT';
INTERSECT: 'INTERSECT';
INTO: 'INTO';
IS: 'IS';
JOIN: 'JOIN';
KEY: 'KEY';
KILL: 'KILL';
LEFT: 'LEFT';
LIKE: 'LIKE';
LINENO: 'LINENO';
LOAD: 'LOAD';
MERGE: 'MERGE';
NATIONAL: 'NATIONAL';
NOCHECK: 'NOCHECK';
NONCLUSTERED: 'NONCLUSTERED';
NOT: 'NOT';
NULL: 'NULL';
NULLIF: 'NULLIF';
OF: 'OF';
OFF: 'OFF';
OFFSETS: 'OFFSETS';
ON: 'ON';
OPEN: 'OPEN';
OPENDATASOURCE: 'OPENDATASOURCE';
OPENQUERY: 'OPENQUERY';
OPENROWSET: 'OPENROWSET';
OPENXML: 'OPENXML';
OPTION: 'OPTION';
OR: 'OR';
ORDER: 'ORDER';
OUTER: 'OUTER';
OVER: 'OVER';
PERCENT: 'PERCENT';
PIVOT: 'PIVOT';
PLAN: 'PLAN';
PRECISION: 'PRECISION';
PRIMARY: 'PRIMARY';
PRINT: 'PRINT';
PROC: 'PROC';
PROCEDURE: 'PROCEDURE';
PUBLIC: 'PUBLIC';
RAISERROR: 'RAISERROR';
READ: 'READ';
READTEXT: 'READTEXT';
RECONFIGURE: 'RECONFIGURE';
REFERENCES: 'REFERENCES';
REPLICATION: 'REPLICATION';
RESTORE: 'RESTORE';
RESTRICT: 'RESTRICT';
RETURN: 'RETURN';
REVERT: 'REVERT';
REVOKE: 'REVOKE';
RIGHT: 'RIGHT';
ROLLBACK: 'ROLLBACK';
ROWCOUNT: 'ROWCOUNT';
ROWGUIDCOL: 'ROWGUIDCOL';
RULE: 'RULE';
SAVE: 'SAVE';
SCHEMA: 'SCHEMA';
SECURITYAUDIT: 'SECURITYAUDIT';
SELECT: 'SELECT';
SEMANTICKEYPHRASETABLE: 'SEMANTICKEYPHRASETABLE';
SEMANTICSIMILARITYDETAILSTABLE: 'SEMANTICSIMILARITYDETAILSTABLE';
SEMANTICSIMILARITYTABLE: 'SEMANTICSIMILARITYTABLE';
SESSION_USER: 'SESSION_USER';
SET: 'SET';
SETUSER: 'SETUSER';
SHUTDOWN: 'SHUTDOWN';
SOME: 'SOME';
STATISTICS: 'STATISTICS';
SYSTEM_USER: 'SYSTEM_USER';
TABLE: 'TABLE';
TABLESAMPLE: 'TABLESAMPLE';
TEXTSIZE: 'TEXTSIZE';
THEN: 'THEN';
TO: 'TO';
TOP: 'TOP';
TRAN: 'TRAN';
TRANSACTION: 'TRANSACTION';
TRUE: 'TRUE';
TRIGGER: 'TRIGGER';
TRUNCATE: 'TRUNCATE';
TRY_CONVERT: 'TRY_CONVERT';
TSEQUAL: 'TSEQUAL';
UNION: 'UNION';
UNIQUE: 'UNIQUE';
UNPIVOT: 'UNPIVOT';
UPDATE: 'UPDATE';
UPDATETEXT: 'UPDATETEXT';
USE: 'USE';
USER: 'USER';
VALUES: 'VALUES';
VARYING: 'VARYING';
VIEW: 'VIEW';
WAITFOR: 'WAITFOR';
WHEN: 'WHEN';
WHERE: 'WHERE';
WHILE: 'WHILE';
WITH: 'WITH';
WITHIN: 'WITHIN';
WRITETEXT: 'WRITETEXT';
INT: 'INT';
BIGINT: 'BIGINT';
NVARCHAR: 'NVARCHAR';
SUM: 'SUM';
// 6. Variables
USER_VARIABLE: '@' [a-zA-Z_][a-zA-Z0-9_]* ;

// 7. Generic Identifiers (Keep this simple; don't put ' in here)
IDENTIFIER: [a-zA-Z_#][a-zA-Z0-9_]* ;

// Arithmetic operators
PLUS: '+';
MINUS: '-';
MULTIPLY: '*';
DIVIDE: '/';

// Symbols
DOT: '.';
COMMA: ',';
SEMICOLON: ';';
EQUALS: '=';
GREATER_THAN: '>';
LESS_THAN: '<';
GREATER_EQUAL: '>=';
LESS_EQUAL: '<=';
NOT_EQUAL: '<>';
LEFT_PAREN: '(';
RIGHT_PAREN: ')';
LEFT_BRACKET: '[';
RIGHT_BRACKET: ']';

// System Variables - start with @@
SYSTEM_VARIABLE: '@@' [a-zA-Z_][a-zA-Z0-9_]*;
//Literals
// Numbers

// Double Quote String - "..."
DOUBLE_QUOTE_STRING: '"' (~'"' | '""')* '"'
// Replace ''  with  ' and \\n with (space)
    { 
        text = self.text
        text= text.replace("''",  "'")
        text= text.replace("\\\n",  " ")
        self.text = text
    };

// Hex String - 0x... or X'...'
//'\\\n' for it take the \\n for us to replace it. cuz it doesn't even read it
// it works but the newline is taking \r\n instread of just \n.
HEX_STRING: 'X\'' [0-9A-Fa-f]+ '\'' | '0'[xX] ( [0-9A-Fa-f] | '\\\n' )+
    {
        text = self.text
        text = text.replace("\\\n", "")
        self.text = text
    };

// Bit String - b'...' or B'...' or 0b...
BIT_STRING: [bB] '\'' [01]+ '\'' | '0'[bB] [01]+  '\\\n' [01]+ 
    {
        text = self.text
        text = text.replace("\\\n", "")
        self.text = text
    };
// HEX_STRING: 'X\'' [0-9A-Fa-f]+ '\'' | '0x' ( [0-9A-Fa-f] | '\\\n' )+

// Comments fragment
INTGER: [0-9]+;
FLOAT: [0-9]+ '.' [0-9]+;
// Single Line Comment - -- or //
SINGLE_LINE_COMMENT: ('--' | '//') ~[\r\n]* -> skip;

// 8. Fix the Comment Rule (Use a non-greedy match that includes newlines)
NESTED_BLOCK_COMMENT
    : '/*' ( NESTED_BLOCK_COMMENT | . | [\r\n] )*? '*/' -> skip
    ;

// Whitespace - skip
WS: [ \t\r\n]+ -> skip;
// python src/lexer_test.py
// insert query tests in src/tests.sql
//   java -jar "C:\Users\sulim\Downloads\antlr-4.13.2-complete.jar" -Dlanguage=Python3 grammar/SQL.g4