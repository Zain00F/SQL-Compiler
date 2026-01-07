parser grammar SQLPARSER;

options {
    tokenVocab=SQL;
}

sqlScript: sqlStatement* EOF;
sqlStatement: selectStatement
            | insertStatement
            | updateStatement
            | deleteStatement
            | unifiers
            | SEMICOLON;

//ANCHOR SELECET STATEMENT
selectStatement: 
    (WITH withExpression (COMMA withExpression)*)?
    SELECT 
    (distinctClause)? 
    (TOP expression PERCENT?
    (WITH TIES)?)?
    columnList 
    (INTO columnName)?
    (FROM tableName)? 
    (joinClause)* 
    (WHERE expression)?
    (GROUP BY columnList)?
    (HAVING expression)?
    (ORDER BY orderByList)?
    (FOR forClause)? //TODO
    (OPTION)? //TODO
    SEMICOLON?;

columnList: column (COMMA column)* ;  // * or list of columns
column: (columnName | sumColumn | expression) (asAlias|assignAlias)?;  // column AS alias (alias is optional)
columnName: (alias | MULTIPLY)  (DOT IDENTIFIER)* (DOT MULTIPLY)?;

assignAlias: EQUALS expression;
asAlias: AS? alias;  // table.column or just column
alias: IDENTIFIER | SINGLE_QUOTE_STRING | DOUBLE_QUOTE_STRING | BRACKET_IDENTIFIER;
// tableName

tableName: IDENTIFIER (DOT IDENTIFIER)* (asAlias)?;  // schema.table or just table

sumColumn: (SUM | YEAR | COUNT) LEFT_PAREN IDENTIFIER RIGHT_PAREN; 
// DISTINCT
distinctClause: DISTINCT | ALL;

// EXPRESSION
expression: orExpression;  // Start with highest precedence
orExpression: andExpression (OR andExpression)*;
andExpression: notExpression (AND notExpression)*;
notExpression: NOT notExpression | comparisonExpression;
comparisonExpression: additiveExpression 
                    ( (EQUALS | NOT_EQUAL | GREATER_THAN | LESS_THAN | GREATER_EQUAL | LESS_EQUAL) additiveExpression )?
                    | additiveExpression IN LEFT_PAREN valueList RIGHT_PAREN
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
                 |sumColumn
                 ;
literal: INTGER | FLOAT | SINGLE_QUOTE_STRING | DOUBLE_QUOTE_STRING | NULL | TRUE | FALSE;
valueList: literal (COMMA literal)*;

// ORDER BY
orderByList: orderByItem (COMMA orderByItem)*;
orderByItem: columnName (ASC | DESC)?;

tableSource: tableName (AS? alias)? (joinClause)*;
joinClause: (INNER | LEFT | RIGHT | FULL | CROSS)? JOIN columnList ON expression;

withExpression: IDENTIFIER LEFT_PAREN columnList RIGHT_PAREN AS (cteQuery)?;
cteQuery:LEFT_PAREN ((unifiers)? selectStatement)* RIGHT_PAREN;
unifiers: (UNION ALL
        | INTERSECT
        | UNION
        | EXCEPT);

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
//ANCHOR - INSERT STATEMENT
insertStatement: INSERT INTO tableName 
                 (LEFT_PAREN columnList RIGHT_PAREN)?
                 VALUES LEFT_PAREN valueList RIGHT_PAREN
                 SEMICOLON?;
                 
//ANCHOR - UPDATE STATEMENT
updateStatement: UPDATE tableName SET assignmentList (WHERE expression)? SEMICOLON?;
assignmentList: assignment (COMMA assignment)*;
assignment: columnName EQUALS expression
          | columnName ASSIGN_ADD expression
          | columnName ASSIGN_MIN expression
          ;
//ANCHOR - DELETE STATEMENT
deleteStatement: DELETE FROM tableName (WHERE expression)? SEMICOLON?;

