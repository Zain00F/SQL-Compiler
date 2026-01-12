parser grammar SQLPARSER;

options {
    tokenVocab=SQL;
}

// ======================================================
// 1. TOP-LEVEL ENTRY POINTS
// ======================================================

sqlScript: sqlStatement* EOF;

sqlStatement: selectStatement
            | insertStatement
            | updateStatement
            | deleteStatement
            | unifiers
            | SEMICOLON;

// ======================================================
// 2. MAIN STATEMENTS
// ======================================================

// --- SELECT STATEMENT ---
selectStatement: 
    (WITH withExpression (COMMA withExpression)*)?
    SELECT 
    (distinctClause)? 
    (TOP expression PERCENT?
    (WITH TIES)?)?
    columnList 
    (INTO columnName)?//todo
    (FROM tableName)? 
    (joinClause)* 
    (WHERE whereExpression)?
    (GROUP BY columnList)?
    (HAVING expression)?
    (ORDER BY orderByList)?
    (WINDOW windowClause)?
    (OPTION optionClause)? 
    SEMICOLON?;

// --- INSERT STATEMENT ---
insertStatement: INSERT INTO tableName 
                 (LEFT_PAREN columnList RIGHT_PAREN)?
                 VALUES LEFT_PAREN valueList RIGHT_PAREN
                 SEMICOLON?;
                 
// --- UPDATE STATEMENT ---
updateStatement: 
    (WITH withExpression (COMMA withExpression)*)?
    UPDATE 
    (TOP expression PERCENT?
    (WITH TIES)?)? 
    tableName
    SET assignmentList
    (FROM tableName)?
    (joinClause)*  
    (WHERE whereExpression)?
    (OPTION optionClause)? 
    SEMICOLON?;

// --- DELETE STATEMENT ---
deleteStatement: DELETE FROM tableName (WHERE expression)? SEMICOLON?;

// ======================================================
// 3. CLAUSE DEFINITIONS
// ======================================================

distinctClause: DISTINCT | ALL;

columnList: column (COMMA column)* ;

column: (columnName | sumColumn | expression) (asAlias|assignAlias)?;

columnName: (alias | MULTIPLY) (DOT IDENTIFIER)* (DOT MULTIPLY)?;

tableName: IDENTIFIER (DOT IDENTIFIER)* (asAlias)?;

tableSource: tableName (AS? alias)? (joinClause)*;

joinClause: (INNER | LEFT | RIGHT | FULL | CROSS)? JOIN columnList ON expression;

orderByList: orderByItem (COMMA orderByItem)*;

orderByItem: columnName (ASC | DESC)?;

withExpression: IDENTIFIER (LEFT_PAREN columnList RIGHT_PAREN)? AS (cteQuery)?;

cteQuery: LEFT_PAREN ((unifiers)? selectStatement)* RIGHT_PAREN;

unifiers: (UNION ALL
        | INTERSECT
        | UNION
        | EXCEPT);

// ======================================================
// 4. WINDOW CLAUSE SUB-RULES
// ======================================================

windowClause
    : windowDefinition (COMMA windowDefinition)*
    ;

windowDefinition
    : IDENTIFIER AS LEFT_PAREN windowSpecification RIGHT_PAREN
    ;

windowSpecification
    : (PARTITION BY columnList)? 
      (ORDER BY orderByList)? 
      (rowsOrRangeClause)?
    ;

rowsOrRangeClause
    : (ROWS | RANGE) frameExtent
    ;

frameExtent
    : frameStart
    | BETWEEN frameStart AND frameEnd
    ;

frameStart
    : UNBOUNDED PRECEDING
    | INTGER PRECEDING
    | CURRENT ROW
    ;

frameEnd
    : UNBOUNDED FOLLOWING
    | INTGER FOLLOWING
    | CURRENT ROW
    ;

// ======================================================
// 5. FOR CLAUSE SUB-RULES
// ======================================================

forClause
    : jsonClause | xmlClause | BROWSE;

jsonClause
    : JSON (AUTO | PATH) 
      (COMMA jsonOption)* ;

jsonOption
    : ROOT LEFT_PAREN alias RIGHT_PAREN
    | INCLUDENULLVALUES
    | WITHOUTARRAYWRAPPER
    ;

xmlClause
    : XML (RAW | AUTO | EXPLICIT | PATH) (LEFT_PAREN alias RIGHT_PAREN)?
      (COMMA xmlOption)*
    ;

xmlOption
    : ELEMENTS (XSINIL | ABSENT)?
    | ROOT LEFT_PAREN alias RIGHT_PAREN
    | TYPE
    | XMLDATA
    | XMLSCHEMA (LEFT_PAREN alias RIGHT_PAREN)?
    | BINARY BASE64
    ;

// ======================================================
// 6. OPTION CLAUSE SUB-RULES
// ======================================================

optionClause: LEFT_PAREN queryHint (COMMA queryHint)* RIGHT_PAREN;

queryHint
    : joinHint
    | groupHint
    | simpleHint
    | valueHint
    | optimizeForHint
    | labelHint
    | temporalHint
    ;

joinHint: (LOOP | HASH | MERGE) (JOIN | UNION);

groupHint: (HASH | ORDER) GROUP;

simpleHint
    : RECOMPILE 
    | FORCE ORDER 
    | ROBUST PLAN 
    | EXPAND VIEWS 
    | (FORCE | DISABLE) EXTERNALPUSHDOWN
    ;

valueHint
    : (FAST | MAXDOP | MAXRECURSION) INTGER
    | QUERYGOVERNORCOSTLIMIT INTGER
    ;

optimizeForHint
    : OPTIMIZE FOR LEFT_PAREN variableValue (COMMA variableValue)* RIGHT_PAREN
    ;

variableValue
    : USER_VARIABLE EQUALS (literal | UNKNOWN)
    ;

labelHint
    : LABEL EQUALS (IDENTIFIER | SINGLE_QUOTE_STRING)
    ;

temporalHint
    : FOR TIMESTAMP AS OF SINGLE_QUOTE_STRING
    ;
    
// ======================================================
// 7. WHERE CLAUSE SUB-RULES
// ======================================================
whereExpression: 
    expression |
    whereCte cteQuery   ;
whereCte: (EXISTS | IDENTIFIER IN);


// ======================================================
// 8. UPDATE/INSERT SHARED SUB-RULES
// ======================================================

assignmentList: assignment (COMMA assignment)*;

assignment: columnName EQUALS expression
          | columnName ASSIGN_ADD expression
          | columnName ASSIGN_MIN expression
          | columnName ASSIGN_MUL expression
          ;

// ======================================================
// 9. EXPRESSIONS AND LITERALS
// ======================================================

expression: orExpression;

orExpression: andExpression (OR andExpression)*;

andExpression: notExpression (AND notExpression)*;

notExpression: NOT notExpression | comparisonExpression;

comparisonExpression: additiveExpression 
                    ( (EQUALS | NOT_EQUAL | GREATER_THAN | LESS_THAN | GREATER_EQUAL | LESS_EQUAL| NOT_GREATER_THAN | NOT_LESS_THAN) additiveExpression )?
                    | additiveExpression NOT? IN LEFT_PAREN (valueList) RIGHT_PAREN
                    | additiveExpression LIKE SINGLE_QUOTE_STRING
                    | additiveExpression IS NOT? NULL
                    ;

additiveExpression: multiplicativeExpression ((PLUS | MINUS) multiplicativeExpression)*;

multiplicativeExpression: primaryExpression ((MULTIPLY | DIVIDE) primaryExpression)*;

primaryExpression: literal
                 | columnName
                 | USER_VARIABLE
                 | SYSTEM_VARIABLE
                 | LEFT_PAREN expression RIGHT_PAREN
                 | sumColumn
                 ;

literal: INTGER | FLOAT | SINGLE_QUOTE_STRING | DOUBLE_QUOTE_STRING | NULL | TRUE | FALSE;

valueList: literal (COMMA literal)*;

// ======================================================
// 10. CORE ATOMS AND ALIASES
// ======================================================

sumColumn: (SUM | YEAR | COUNT | AVG) LEFT_PAREN IDENTIFIER RIGHT_PAREN; 

assignAlias: EQUALS expression;

asAlias: AS? alias;

alias: IDENTIFIER | SINGLE_QUOTE_STRING | DOUBLE_QUOTE_STRING | BRACKET_IDENTIFIER;