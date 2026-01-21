from typing import List, Optional, Union

from SQLPARSER import SQLPARSER
from SQLPARSERVisitor import SQLPARSERVisitor
from .semantic_ast import ( 
    EXISTS,
    ASTNode,
    BinaryComparisonExprNode,
    BinaryNotEqualExprNode,
    BlockNode,
    IfNode,
    IsNullNode,
    LikeNode,
    LiteralNode,
    SelectNode,
    SelectSetQuantifierNode,
    InsertNode,
    SubqueryExprNode,
    TruncateNode,
    UpdateNode,
    DeleteNode,
    AlterTableNode,
    DropTableNode,
    TruncateTableNode,
    GoNode,
    TableIdentifierNode,
    ColumnIdentifierNode,
    ColumnListNode,
    UseNode,
    ValueListNode,
    WhereNode,
    GroupByNode,
    HavingNode,
    OrderByNode,
    OrderByItemNode,
    SortDirectionNode,
    JoinNode,
    SetClauseNode,
    AssignmentNode,
    ExprNode,
    BinaryAndExprNode,
    BinaryOrExprNode,
    BinaryEqualExprNode,
    BinaryGreaterExprNode,
    BinaryLessExprNode,
    BinaryGreaterEqualExprNode,
    BinaryLessEqualExprNode,
    NumberLiteralNode,
    StringLiteralNode,
    BinaryAddExprNode,
    BinarySubExprNode,
    BinaryMulExprNode,
    BinaryDivExprNode,
    CreateDatabaseNode,
    CreateTableNode,
    CreateViewNode,
    CreateIndexNode,
    DatabaseIdentifierNode,
    ViewIdentifierNode,
    IndexIdentifierNode,
    ColumnDefinitionNode,
    DataTypeNode,
    ColumnConstraintNode,
    NotNullConstraintNode,
    NullConstraintNode,
    PrimaryKeyConstraintNode,
    UniqueConstraintNode,
    DefaultConstraintNode,
    IdentityConstraintNode,
    CheckConstraintNode,
    ForeignKeyConstraintNode,
    TableConstraintNode,
    IncludeColumnsNode,
)

AstOrList = Union[ASTNode, List[ASTNode]]


class ASTBuilder(SQLPARSERVisitor):

    # ---------- sqlScript ----------

    def visitSqlScript(self, ctx: SQLPARSER.SqlScriptContext) -> List[ASTNode]:
        ast_statements: List[ASTNode] = []
        for stmt_ctx in ctx.sqlStatement():
            stmt_ast = self.visit(stmt_ctx)
            if stmt_ast is not None:
                ast_statements.append(stmt_ast)
        return ast_statements

    # ---------- sqlStatement ----------

    def visitSqlStatement(
        self, ctx: SQLPARSER.SqlStatementContext
    ) -> Optional[ASTNode]:
        if ctx.selectStatement():
            return self.visit(ctx.selectStatement())
        if ctx.insertStatement():
            return self.visit(ctx.insertStatement())
        if ctx.updateStatement():
            return self.visit(ctx.updateStatement())
        if ctx.deleteStatement():
            return self.visit(ctx.deleteStatement())
        if ctx.createStatement():
            return self.visit(ctx.createStatement())
        if ctx.ifStatement():
            return self.visit(ctx.ifStatement())   
        if ctx.beginEndBlock():
            return self.visit(ctx.beginEndBlock()) 
        if ctx.goStatement():
            return self.visit(ctx.goStatement())
        if ctx.truncateStatement():
            return self.visit(ctx.truncateStatement())
        if ctx.useStatement():                   
            return self.visit(ctx.useStatement())
        
        return None

    # ---------- SELECT ----------

    def visitSelectStatement(self, ctx: SQLPARSER.SelectStatementContext) -> SelectNode:

        node = SelectNode()

        # DISTINCT / ALL
        if ctx.distinctClause():
            quant_text = ctx.distinctClause().getText()
            node.add(SelectSetQuantifierNode(text=quant_text))

        # column
        if ctx.columnList():
            first_col_list_ctx = ctx.columnList(0)
            col_list_ast = self.visit(first_col_list_ctx)
            if col_list_ast:
                node.add(col_list_ast)

        # FROM tableName
        if ctx.tableName():
            table_ast = self.visit(ctx.tableName())
            if table_ast:
                node.add(table_ast)

        # JOINs
        if ctx.joinClause():
            for j_ctx in ctx.joinClause():
                j_ast = self.visit(j_ctx)
                if j_ast:
                    node.add(j_ast)

        # WHERE
        where_expr_ctx = None

        if getattr(ctx, "whereExpression", None) and ctx.whereExpression():
            where_expr_ctx = ctx.whereExpression()
        else:
            found_where = False
            for ch in ctx.children:
                if getattr(ch, "symbol", None) and ch.symbol.text.upper() == "WHERE":
                    found_where = True
                    continue
                if found_where and isinstance(ch, SQLPARSER.ExpressionContext):
                    where_expr_ctx = ch
                    break

        if where_expr_ctx is not None:
            where = WhereNode()
            expr_ast = self.visit(where_expr_ctx)
            if expr_ast:
                where.add(expr_ast)
            node.add(where)

        # GROUP BY
   
        children = list(ctx.getChildren())
        if any(
            getattr(ch, "symbol", None) and ch.symbol.text == "GROUP" for ch in children
        ):
       
            for ch in ctx.children:
                if isinstance(ch, SQLPARSER.ColumnListContext):
                    group_cols = self.visit(ch)
                    if group_cols:
                        gnode = GroupByNode()
                        gnode.add(group_cols)
                        node.add(gnode)
                        break

        # HAVING
        # (HAVING expression)?
        for ch in ctx.children:
            if getattr(ch, "symbol", None) and ch.symbol.text == "HAVING":
                found_expr = None
                start_collect = False
                for c2 in ctx.children:
                    if c2 is ch:
                        start_collect = True
                        continue
                    if start_collect and isinstance(c2, SQLPARSER.ExpressionContext):
                        found_expr = c2
                        break
                if found_expr is not None:
                    having = HavingNode()
                    having_expr = self.visit(found_expr)
                    if having_expr:
                        having.add(having_expr)
                        node.add(having)
                break

        # ORDER BY
        # (ORDER BY orderByList)?
        if getattr(ctx, "orderByList", None) and ctx.orderByList():
            order_ast = self.visit(ctx.orderByList())
            if order_ast:
                node.add(order_ast)

        return node

    # ---------- INSERT ----------

    def visitInsertStatement(self, ctx):
        node = InsertNode()

        node.add(self.visit(ctx.tableName()))
        if ctx.columnList():
            node.add(self.visit(ctx.columnList()))

        src = ctx.insertSource()
        if src:
            src_ast = self.visit(src)
            if src_ast:
                node.add(src_ast)

        return node

    def visitInsertSource(self, ctx):
        if ctx.insertValueList():
            return self.visit(ctx.insertValueList())

        if ctx.selectStatement():
            return self.visit(ctx.selectStatement())        
            

        return None

    def visitInsertValueList(
        self, ctx: SQLPARSER.InsertValueListContext
    ) -> ValueListNode:
        vlist = ValueListNode()

        expr_lists = ctx.expressionList()
        if not expr_lists:
            return vlist

        for expr_list_ctx in expr_lists:
            for e_ctx in expr_list_ctx.expression():
                expr_ast = self.visit(e_ctx)
                if expr_ast:
                    vlist.add(expr_ast)

        return vlist

    # ---------- UPDATE ----------

    def visitUpdateStatement(self, ctx: SQLPARSER.UpdateStatementContext) -> UpdateNode:
        
        node = UpdateNode()

        table_ast = self.visit(ctx.tableName())
        node.add(table_ast)

        set_clause_ast = self._build_set_clause(ctx)
        if set_clause_ast:
            node.add(set_clause_ast)

        if ctx.whereExpression():
            where = WhereNode()
            expr_ast = self.visit(ctx.whereExpression())
            if expr_ast:
                where.add(expr_ast)
            node.add(where)

        return node

    def _build_set_clause(
        self, ctx: SQLPARSER.UpdateStatementContext
    ) -> Optional[SetClauseNode]:
        
        assign_list_ctx = ctx.assignmentList()
        if assign_list_ctx is None:
            return None

        clause = SetClauseNode()
        for assign_ctx in assign_list_ctx.assignment():
            assign_ast = self.visit(assign_ctx)
            if assign_ast:
                clause.add(assign_ast)
        return clause

    def _build_assignment_from_ctx(self, ctx) -> Optional[AssignmentNode]:
        
        if not (hasattr(ctx, "columnName") and hasattr(ctx, "expression")):
            return None

        col_ast = self.visit(ctx.columnName())
        expr_ast = self.visit(ctx.expression())
        if not col_ast or not expr_ast:
            return None

        assign = AssignmentNode()
        assign.add(col_ast)
        assign.add(expr_ast)
        return assign

    def visitAssignment(
        self, ctx: SQLPARSER.AssignmentContext
    ) -> Optional[AssignmentNode]:
        return self._build_assignment_from_ctx(ctx)

    # ---------- DELETE ----------

    def visitDeleteStatement(self, ctx: SQLPARSER.DeleteStatementContext) -> DeleteNode:
       
        node = DeleteNode()

        table_source_ctx = ctx.tableSource()
        if table_source_ctx is not None:
            table_ast = self.visit(table_source_ctx)
            if table_ast:
                node.add(table_ast)

        if ctx.expression():
            where = WhereNode()
            expr_ast = self.visit(ctx.expression())
            if expr_ast:
                where.add(expr_ast)
            node.add(where)

        return node

    # ---------- Identifiers / Lists ----------

    def visitTableSource(
        self, ctx: SQLPARSER.TableSourceContext
    ) -> TableIdentifierNode:
        
        return self.visit(ctx.tableName())

    # ---------- Identifiers / Lists ----------

    def visitTableName(self, ctx: SQLPARSER.TableNameContext) -> TableIdentifierNode:
        return TableIdentifierNode(text=ctx.getText())

    def visitColumnName(self, ctx: SQLPARSER.ColumnNameContext) -> ColumnIdentifierNode:
        return ColumnIdentifierNode(text=ctx.getText())

    def visitColumnList(self, ctx: SQLPARSER.ColumnListContext) -> ColumnListNode:
        node = ColumnListNode()
        for col_ctx in ctx.column():
            col_ast = self.visit(col_ctx)
            if col_ast:
                node.add(col_ast)
        return node

    def visitColumn(self, ctx: SQLPARSER.ColumnContext) -> ASTNode:
        if ctx.columnName():
            base = self.visit(ctx.columnName())
        elif ctx.sumColumn():
            base = self.visit(ctx.sumColumn())
        else:
            base = self.visit(ctx.expression())

        # alias (AS 'alias')
        if ctx.asAlias():
            alias_text = ctx.asAlias().alias().getText()
            base.add(StringLiteralNode(text=alias_text))

        return base
 
    # ---------- Literals & Functions ----------
    
    def visitLiteral(self, ctx):
        text = ctx.getText()

        # NULL
        if ctx.NULL():
            return LiteralNode(text="NULL")

        # Integer 
        if ctx.INTGER():
            return NumberLiteralNode(int(text))

        # Float 
        if ctx.FLOAT():
            return NumberLiteralNode(float(text))

        # String literal: 'TEXT'
        if ctx.SINGLE_QUOTE_STRING():
            raw = ctx.SINGLE_QUOTE_STRING().getText()
            return StringLiteralNode(text=text) 

        # Identifier literal 
        if ctx.IDENTIFIER():
            return LiteralNode(text)

        # Fallback
        return LiteralNode(text)

    def visitSignedLiteral(self, ctx):
        node = self.visit(ctx.literal())

        if ctx.MINUS():
            if isinstance(node, NumberLiteralNode):
                node.text = -node.text
            else:
                node.text = "-" + str(node.text)

        return node


    


    # ---------- Expressions (AND / OR / Comparisons) ----------

    def visitExpression(self, ctx: SQLPARSER.ExpressionContext) -> ExprNode:
        return self.visit(ctx.orExpression())

    def visitWhereExpression(self, ctx: SQLPARSER.WhereExpressionContext) -> ExprNode:
        return self.visit(ctx.expression())

    def visitWhereCte(self, ctx: SQLPARSER.WhereCteContext) -> ExprNode:
        return ExprNode(text=ctx.getText())

    def visitOrExpression(self, ctx: SQLPARSER.OrExpressionContext) -> ExprNode:
        # orExpression: andExpression (OR andExpression)*
        and_exprs = [self.visit(a) for a in ctx.andExpression()]
        expr = and_exprs[0]
        for rhs in and_exprs[1:]:
            node = BinaryOrExprNode()
            node.add(expr)
            node.add(rhs)
            expr = node
        return expr

    def visitAndExpression(self, ctx: SQLPARSER.AndExpressionContext) -> ExprNode:
        # andExpression: notExpression (AND notExpression)*
        not_exprs = [self.visit(n) for n in ctx.notExpression()]
        expr = not_exprs[0]
        for rhs in not_exprs[1:]:
            node = BinaryAndExprNode()
            node.add(expr)
            node.add(rhs)
            expr = node
        return expr

    def visitAdditiveExpression(
        self, ctx: SQLPARSER.AdditiveExpressionContext
    ) -> ExprNode:

        children = list(ctx.getChildren())
        expr: Optional[ExprNode] = None
        pending_op: Optional[str] = None  

        for ch in children:
            # كل multiplicativeExpression
            if isinstance(ch, SQLPARSER.MultiplicativeExpressionContext):
                sub = self.visit(ch)
                if expr is None:
                    expr = sub
                else:
                    if pending_op == "+":
                        node = BinaryAddExprNode()
                    elif pending_op == "-":
                        node = BinarySubExprNode()
                    else:
                        return ExprNode(
                            children=[StringLiteralNode(text=ctx.getText())]
                        )
                    node.add(expr)
                    node.add(sub)
                    expr = node
                    pending_op = None
            else:
                text = getattr(ch, "getText", lambda: "")()
                if text == "+":
                    pending_op = "+"
                elif text == "-":
                    pending_op = "-"

        if expr is None:
            expr = ExprNode()
            expr.add(StringLiteralNode(text=ctx.getText()))
        return expr

    def visitMultiplicativeExpression(
        self, ctx: SQLPARSER.MultiplicativeExpressionContext
    ) -> ExprNode:

        children = list(ctx.getChildren())
        expr: Optional[ExprNode] = None
        pending_op: Optional[str] = None  

        for ch in children:
            if isinstance(ch, SQLPARSER.PrimaryExpressionContext):
                sub = self.visit(ch)
                if expr is None:
                    expr = sub
                else:
                    if pending_op == "*":
                        node = BinaryMulExprNode()
                    elif pending_op == "/":
                        node = BinaryDivExprNode()
                    else:
                        return ExprNode(
                            children=[StringLiteralNode(text=ctx.getText())]
                        )
                    node.add(expr)
                    node.add(sub)
                    expr = node
                    pending_op = None
            else:
                text = getattr(ch, "getText", lambda: "")()
                if text == "*":
                    pending_op = "*"
                elif text == "/":
                    pending_op = "/"

        if expr is None:
            expr = ExprNode()
            expr.add(StringLiteralNode(text=ctx.getText()))
        return expr

    def visitComparisonExpression(
        self, ctx: SQLPARSER.ComparisonExpressionContext
    ) -> ExprNode:
        

        if ctx.IS() and ctx.NULL():
            left_expr = self.visit(ctx.additiveExpression(0))
            
            is_negated = bool(ctx.NOT())  
            return IsNullNode(left_expr, negated=is_negated)

       

        # ---------- IN / NOT IN ----------
        # if ctx.IN():
        #     left = self.visit(ctx.additiveExpression(0))

        #     vlist_ctx = ctx.valueList(0) if ctx.valueList() else None
        #     vlist_ast = (
        #         self.visit(vlist_ctx) if vlist_ctx else None
        #     ) 

        #     or_expr = None
        #     values = vlist_ast.children if isinstance(vlist_ast, ValueListNode) else []
        #     for val in values:
        #         eq = BinaryEqualExprNode()
        #         eq.add(left)
        #         eq.add(val)
        #         if or_expr is None:
        #             or_expr = eq
        #         else:
        #             new_or = BinaryOrExprNode()
        #             new_or.add(or_expr)
        #             new_or.add(eq)
        #             or_expr = new_or

        #     if ctx.NOT():
        #         not_node = ExprNode()
        #         not_node.add(or_expr)
        #         return not_node

        #     return
        if ctx.IN():
            left = self.visit(ctx.additiveExpression(0))

            vlist_ctx = ctx.valueList(0)
            vlist_ast = self.visit(vlist_ctx)

            node = ExprNode()
            if ctx.NOT():
                node.add(StringLiteralNode(text="NOT"))

            node.add(StringLiteralNode(text="IN"))
            node.add(left)

            if vlist_ast:
                node.add(vlist_ast)

            return node

            
        # ---------- BETWEEN ----------
        if ctx.BETWEEN():
            col = self.visit(ctx.additiveExpression(0))
            low = self.visit(ctx.additiveExpression(1))
            high = self.visit(ctx.additiveExpression(2))

            ge = BinaryGreaterEqualExprNode()
            ge.add(col)
            ge.add(low)

            le = BinaryLessEqualExprNode()
            le.add(col)
            le.add(high)

            and_node = BinaryAndExprNode()
            and_node.add(ge)
            and_node.add(le)

            return and_node

        add_exprs = (
            list(ctx.additiveExpression()) if hasattr(ctx, "additiveExpression") else []
        )

        # ---------- LIKE / NOT LIKE ----------
        if ctx.LIKE():        
            left = self.visit(add_exprs[0]) if add_exprs else None  

            pattern_token = None
            try:
                pattern_token = ctx.SINGLE_QUOTE_STRING(0)
            except TypeError:
                sqs = ctx.SINGLE_QUOTE_STRING()
                if isinstance(sqs, list) and sqs:
                    pattern_token = sqs[0]
            pattern = (
                StringLiteralNode(text=pattern_token.getText())
                if pattern_token
                else (self.visit(add_exprs[1]) if len(add_exprs) >= 2 else None)
            )

            if left and pattern:
               
                is_negated = bool(ctx.NOT())             
                return LikeNode(left, pattern, negated=is_negated)

            # fallback
            node = ExprNode()
            node.add(StringLiteralNode(text="LIKE"))
            node.add(StringLiteralNode(text=ctx.getText()))
            return node
        
        if hasattr(ctx, 'existsExpression') and ctx.existsExpression():
            return self.visit(ctx.existsExpression())

        if ctx.getChildCount() == 1:
            return self.visit(ctx.getChild(0))

        # ---------- (=, >, <, >=, <=, <>) ----------
        if len(add_exprs) >= 2:
            left = self.visit(add_exprs[0])
            right = self.visit(add_exprs[1])

            if ctx.EQUALS():
                node = BinaryEqualExprNode()
            elif ctx.GREATER_THAN():
                node = BinaryGreaterExprNode()
            elif ctx.LESS_THAN():
                node = BinaryLessExprNode()
            elif ctx.GREATER_EQUAL():
                node = BinaryGreaterEqualExprNode()
            elif ctx.LESS_EQUAL():
                node = BinaryLessEqualExprNode()
            elif ctx.NOT_EQUAL():
                node = BinaryNotEqualExprNode()
            else:
                node = BinaryComparisonExprNode()

            node.add(left)
            node.add(right)
            return node

        # fallback:
        text = ctx.getText()
        node = ExprNode()
        node.add(StringLiteralNode(text=text))
        return node
    
    def visitExistsExpression(self, ctx):
        is_negated = True if ctx.NOT() else False
        node = EXISTS(negated=is_negated)        
        select_ast = self.visit(ctx.selectStatement())
        if select_ast:
            node.add(select_ast)

        return node
    

    def visitIdentityConstraint(self, ctx) -> IdentityConstraintNode:
        return IdentityConstraintNode()

    # ---------- SELECT helpers ----------

    def visitOrderByList(self, ctx: SQLPARSER.OrderByListContext) -> OrderByNode:
        node = OrderByNode()
        for item_ctx in ctx.orderByItem():
            item_ast = self.visit(item_ctx)
            if item_ast:
                node.add(item_ast)
        return node

    def visitOrderByItem(self, ctx: SQLPARSER.OrderByItemContext) -> OrderByItemNode:
        item = OrderByItemNode()
        col_ast = self.visit(ctx.columnName())
        item.add(col_ast)

        if ctx.ASC():
            item.add(SortDirectionNode(text="ASC"))
        elif ctx.DESC():
            item.add(SortDirectionNode(text="DESC"))

        return item



    def visitJoinClause(self, ctx: SQLPARSER.JoinClauseContext) -> JoinNode:
        node = JoinNode()

        # ---------- JOIN TYPE ----------
        if ctx.INNER():
            join_type = "INNER"
        elif ctx.LEFT():
            join_type = "LEFT"
        elif ctx.RIGHT():
            join_type = "RIGHT"
        elif ctx.FULL():
            join_type = "FULL"
        else:
            join_type = "JOIN"

        node.add(StringLiteralNode(text=join_type))

        # ---------- JOIN TABLE ----------
        if ctx.columnList():
            table_ast = self.visit(ctx.columnList())
            node.add(table_ast)

        # ---------- ON CONDITION ----------
        if ctx.expression():
            on_expr = self.visit(ctx.expression())
            node.add(on_expr)

        return node

    # ---------- CREATE * ----------

    def visitCreateStatement(self, ctx: SQLPARSER.CreateStatementContext) -> ASTNode:
        if ctx.createView():
            return self.visit(ctx.createView())
        if ctx.createObject():
            return self.visit(ctx.createObject())
        return None

    def visitCreateObject(self, ctx: SQLPARSER.CreateObjectContext) -> ASTNode:
        if ctx.createTable():
            return self.visit(ctx.createTable())
        if ctx.createDatabase():
            return self.visit(ctx.createDatabase())
        if ctx.createIndex():
            return self.visit(ctx.createIndex())
        return None

    def visitCreateDatabase(
        self, ctx: SQLPARSER.CreateDatabaseContext
    ) -> CreateDatabaseNode:
        node = CreateDatabaseNode()
        db_name = self.visit(ctx.databaseName())
        node.add(db_name)
        return node

    def visitDatabaseName(
        self, ctx: SQLPARSER.DatabaseNameContext
    ) -> DatabaseIdentifierNode:
        return DatabaseIdentifierNode(text=ctx.IDENTIFIER().getText())

    def visitCreateTable(self, ctx: SQLPARSER.CreateTableContext) -> CreateTableNode:
        node = CreateTableNode()
        table_ast = self.visit(ctx.tableName())
        node.add(table_ast)

        #  TABLE name ( columnElementList )
        if ctx.tableElementList():
            for elem_ctx in ctx.tableElementList().tableElement():
                elem_ast = self.visit(elem_ctx)
                if elem_ast:
                    node.add(elem_ast)
        # TABLE name AS selectStatement
        elif ctx.selectStatement():
            select_ast = self.visit(ctx.selectStatement())
            if select_ast:
                node.add(select_ast)

        return node

    def visitTableElement(self, ctx: SQLPARSER.TableElementContext) -> ASTNode:
        if ctx.columnDefinition():
            return self.visit(ctx.columnDefinition())
        if ctx.tableConstraint():
            return self.visit(ctx.tableConstraint())
        return None

    def visitColumnDefinition(
        self, ctx: SQLPARSER.ColumnDefinitionContext
    ) -> ColumnDefinitionNode:
        node = ColumnDefinitionNode()

        # columnName
        col_ast = self.visit(ctx.columnName())
        node.add(col_ast)

        # dataType
        dt_ast = self.visit(ctx.dataType())
        node.add(dt_ast)

        # nullability: NOT NULL / NULL
        if ctx.nullability():
            null_ctx = ctx.nullability()
            if null_ctx.NOT():
                node.add(NotNullConstraintNode())
            else:
                node.add(NullConstraintNode())

        # column constraints (PRIMARY KEY, IDENTITY, etc.)
        if ctx.columnConstraint():
            for c in ctx.columnConstraint():
                constraint_ast = self.visit(c)
                if constraint_ast:
                    node.add(constraint_ast)

        return node

    def visitConstraintDefinition(
        self, ctx: SQLPARSER.ConstraintDefinitionContext
    ) -> ColumnConstraintNode:
        if ctx.primaryKeyConstraint():
            return self.visit(ctx.primaryKeyConstraint())
        if ctx.foreignKeyConstraint():
            return self.visit(ctx.foreignKeyConstraint())
        if ctx.uniqueConstraint():
            return self.visit(ctx.uniqueConstraint())
        if ctx.checkConstraint():
            return self.visit(ctx.checkConstraint())
        return ColumnConstraintNode()

    def visitDataType(self, ctx: SQLPARSER.DataTypeContext) -> DataTypeNode:
        return DataTypeNode(text=ctx.getText())

    def visitCheckConstraint(
        self, ctx: SQLPARSER.CheckConstraintContext
    ) -> CheckConstraintNode:
        node = CheckConstraintNode()
        expr_ast = self.visit(ctx.expression())
        if expr_ast:
            node.add(expr_ast)
        return node

    def visitForeignKeyConstraint(
        self, ctx: SQLPARSER.ForeignKeyConstraintContext
    ) -> ForeignKeyConstraintNode:
        node = ForeignKeyConstraintNode()
        # FOREIGN KEY (columnList) REFERENCES tableName (columnList)
        cols_local = self.visit(ctx.columnList(0))
        ref_table = self.visit(ctx.tableName())
        cols_ref = self.visit(ctx.columnList(1))
        node.add(cols_local)
        node.add(ref_table)
        node.add(cols_ref)
        return node
    
    def visitPrimaryExpression(self, ctx):
    # (SELECT ...)
        if ctx.selectStatement():
            select_ast = self.visit(ctx.selectStatement())
            return SubqueryExprNode(select_ast)

        # (expression)
        if ctx.expression():
            return self.visit(ctx.expression())

        return self.visitChildren(ctx)

    def visitPrimaryKeyConstraint(self, ctx):
        node = PrimaryKeyConstraintNode()
        for col_ctx in ctx.columnName():
            col_ast = self.visit(col_ctx)
            if col_ast:
                node.add(col_ast)

        return node

    
    def visitNotExpression(self, ctx):
        if ctx.NOT():
            child = self.visit(ctx.notExpression())        
            if hasattr(child, 'negated'):
                child.negated = not child.negated
                return child
            not_node = ExprNode()
            not_node.add(StringLiteralNode(text="NOT"))
            not_node.add(child)
            return not_node
            
        return self.visitChildren(ctx)
        
    def visitUniqueConstraint(
        self, ctx: SQLPARSER.UniqueConstraintContext
    ) -> UniqueConstraintNode:
        node = UniqueConstraintNode()
        cols = self.visit(ctx.columnList())
        node.add(cols)
        return node

    def visitTableConstraint(
        self, ctx: SQLPARSER.TableConstraintContext
    ) -> TableConstraintNode:
        node = TableConstraintNode()

        if ctx.constraintName():
            cname = ctx.constraintName().IDENTIFIER().getText()
            node.add(StringLiteralNode(text=cname))

        if ctx.primaryKeyConstraint():
            node.add(self.visit(ctx.primaryKeyConstraint()))
        elif ctx.uniqueConstraint():
            node.add(self.visit(ctx.uniqueConstraint()))
        elif ctx.foreignKeyConstraint():
            node.add(self.visit(ctx.foreignKeyConstraint()))
        elif ctx.checkConstraint():
            node.add(self.visit(ctx.checkConstraint()))

        return node

    def visitCreateView(self, ctx: SQLPARSER.CreateViewContext) -> CreateViewNode:
        node = CreateViewNode()
        view_name = self.visit(ctx.viewName())
        node.add(view_name)
        select_ast = self.visit(ctx.selectStatement())
        node.add(select_ast)
        return node

    def visitViewName(self, ctx: SQLPARSER.ViewNameContext) -> ViewIdentifierNode:
        return ViewIdentifierNode(text=ctx.IDENTIFIER().getText())

    def visitCreateIndex(self, ctx: SQLPARSER.CreateIndexContext) -> CreateIndexNode:
        node = CreateIndexNode()

        # INDEX name ON tableName (columnList)
        idx_name = self.visit(ctx.indexName())
        table_ast = self.visit(ctx.tableName())
        cols_ast = self.visit(ctx.columnList())
        node.add(idx_name)
        node.add(table_ast)
        node.add(cols_ast)

        # INCLUDE 
        if ctx.includeClause():
            incl = self.visit(ctx.includeClause())
            if incl:
                node.add(incl)

        # WHERE expression 
        if ctx.expression():
            where = WhereNode()
            expr_ast = self.visit(ctx.expression())
            if expr_ast:
                where.add(expr_ast)
            node.add(where)

        return node

    def visitIndexName(self, ctx: SQLPARSER.IndexNameContext) -> IndexIdentifierNode:
        return IndexIdentifierNode(text=ctx.IDENTIFIER().getText())

    def visitIncludeClause(
        self, ctx: SQLPARSER.IncludeClauseContext
    ) -> IncludeColumnsNode:
        node = IncludeColumnsNode()
        cols = self.visit(ctx.columnList())
        node.add(cols)
        return node

    def visitValueList(self, ctx: SQLPARSER.ValueListContext) -> ValueListNode:
        node = ValueListNode()
        for lit_ctx in ctx.literal():
            lit_ast = self.visit(lit_ctx)
            if lit_ast:
                node.add(lit_ast)
        return node

    def visitSumColumn(self, ctx: SQLPARSER.SumColumnContext) -> ExprNode:
        node = ExprNode()

        # (SUM / MAX / AVG / COUNT)
        func_name = ctx.getChild(0).getText()
        node.add(StringLiteralNode(text=func_name))

        
        expr = self.visit(ctx.expression())
        if expr:
            node.add(expr)

        return node

    def visitScalarFunction(self, ctx: SQLPARSER.ScalarFunctionContext) -> ExprNode:
        node = ExprNode()

        func_name = ctx.getChild(0).getText()
        node.add(StringLiteralNode(text=func_name))

        for expr_ctx in ctx.expression():
            expr = self.visit(expr_ctx)
            if expr:
                node.add(expr)

        return node

    # ---------- GO ----------

    def visitGoStatement(self, ctx: SQLPARSER.GoStatementContext) -> GoNode:
        node = GoNode()
        return node

    # ---------- ALTER / DROP / TRUNCATE ----------

    def visitAlterStatement(
        self, ctx: SQLPARSER.AlterStatementContext
    ) -> AlterTableNode:
        node = AlterTableNode()
        table_ast = self.visit(ctx.tableName())
        node.add(table_ast)
        return node

    def visitDropStatement(self, ctx: SQLPARSER.DropStatementContext) -> DropTableNode:
        node = DropTableNode()
        # DROP TABLE (IF EXISTS)? tableName (COMMA tableName)*
        for t_ctx in ctx.tableName():
            t_ast = self.visit(t_ctx)
            if t_ast:
                node.add(t_ast)
        return node

   
    
    # ---------- IF statement ----------
    
    
    def visitIfStatement(self, ctx):
        node = IfNode()

        # condition
        cond = self.visit(ctx.expression())
        if cond:
            node.add(cond)

        blocks = ctx.sqlStatementOrBlock()

        # THEN
        then_part = self.visit(blocks[0])
        if then_part:
            node.add(then_part)

        # ELSE (optional)
        if len(blocks) > 1:
            else_part = self.visit(blocks[1])
            if else_part:
                node.add(else_part)

        return node

# ---------- BeginEnd ----------
    def visitBeginEndBlock(self, ctx):
        node = BlockNode()
        for stmt in ctx.sqlStatement():
            ast = self.visit(stmt)
            if ast:
                node.add(ast)
        return node
    



# ---------- Use ----------

    def visitUseStatement(self, ctx):
        node = UseNode()
        db_name = ctx.identifier().getText()
        node.add(DatabaseIdentifierNode(db_name))
        return node


    def visitTruncateStatement(self, ctx):
        node = TruncateTableNode() 
        table_ast = self.visit(ctx.tableName())
        
        if table_ast:
            node.add(table_ast)
            
        return node

    