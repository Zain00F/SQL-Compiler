parser grammar SQLPARSER;

options {
    tokenVocab=SQL;
}

sqlScript: sqlStatement* EOF;
sqlStatement: selectStatement
            | insertStatement
            | updateStatement
            | deleteStatement
            | SEMICOLON;

//ANCHOR SELECET STATEMENT
selectStatement: 
    (WITH)? //TODO
    SELECT 
    (distinctClause)? 
    (TOP expression PERCENT?
    (WITH TIES)?)? // TODO
    columnList 
    (INTO columnName)? //TODO
    (FROM tableName)? 
    (joinClause)* 
    (WHERE expression)?
    (GROUP BY columnList)?
    (HAVING expression)?
    (ORDER BY orderByList)?
    (FOR)? //TODO
    (OPTION)? //TODO
    SEMICOLON?;

columnList: column (COMMA column)* ;  // * or list of columns
column: (columnName | sumColumn | expression) (asAlias|assignAlias)?;  // column AS alias (alias is optional)
columnName: (alias | MULTIPLY)  (DOT IDENTIFIER)* (DOT MULTIPLY)?;

assignAlias: EQUALS expression;
asAlias: AS? alias;  // table.column or just column
alias: IDENTIFIER | SINGLE_QUOTE_STRING | DOUBLE_QUOTE_STRING;
// tableName

tableName: IDENTIFIER (DOT IDENTIFIER)* (asAlias)?;  // schema.table or just table

sumColumn: SUM LEFT_PAREN IDENTIFIER RIGHT_PAREN; 
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
                    | additiveExpression IS NULL
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

