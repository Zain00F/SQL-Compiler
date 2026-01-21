from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from typing import List, Optional


class ASTNode(ABC):
    @abstractmethod
    def print(self, indent: str = "") -> None: ...


@dataclass
class ASTComposite(ASTNode):
    children: List[ASTNode] = field(default_factory=list)

    def add(self, child: Optional[ASTNode]) -> None:
        if child is not None:
            self.children.append(child)

    def extend(self, children: List[Optional[ASTNode]]) -> None:
        for c in children:
            self.add(c)

    def print(self, indent=0):
        pad = "  " * indent
        print(f"{pad}{self.__class__.__name__}")
        for child in self.children:
            child.print(indent + 1)


@dataclass
class ASTLeaf(ASTNode):
    text: str
    def print(self, indent=0) -> None:
        pad = "  " * indent
        print(f"{pad}{self.__class__.__name__}")
        print(f"{pad}  Text: {self.text}")

class SelectNode(ASTComposite):
    pass  

class SelectSetQuantifierNode(ASTLeaf):
    pass


class InsertNode(ASTComposite):
    pass  


class UpdateNode(ASTComposite):
    pass  


class DeleteNode(ASTComposite):
    pass 


class AlterTableNode(ASTComposite):
    pass 


class DropTableNode(ASTComposite):
    pass 


class TruncateTableNode(ASTComposite):
    pass  


class GoNode(ASTComposite):
    pass 


# -----------------------------
# CREATE * statements
# -----------------------------


class CreateDatabaseNode(ASTComposite):
    pass  


class CreateTableNode(ASTComposite):
    pass  


class CreateViewNode(ASTComposite):
    pass  


class CreateIndexNode(ASTComposite):
    pass  

class DatabaseIdentifierNode(ASTLeaf):
    pass


class ViewIdentifierNode(ASTLeaf):
    pass


class IndexIdentifierNode(ASTLeaf):
    pass


class ColumnDefinitionNode(ASTComposite):
    pass 

class DataTypeNode(ASTLeaf):
    pass


class ColumnConstraintNode(ASTComposite):
    pass


class NotNullConstraintNode(ColumnConstraintNode):
    pass


class NullConstraintNode(ColumnConstraintNode):
    pass


class PrimaryKeyConstraintNode(ColumnConstraintNode):
    pass


class UniqueConstraintNode(ColumnConstraintNode):
    pass


class DefaultConstraintNode(ColumnConstraintNode):
    pass 

class IdentityConstraintNode(ColumnConstraintNode):
    pass


class CheckConstraintNode(ColumnConstraintNode):
    pass  

class ForeignKeyConstraintNode(ColumnConstraintNode):
    pass  

class TableConstraintNode(ASTComposite):
    pass


class IncludeColumnsNode(ASTComposite):
    pass  

class TableIdentifierNode(ASTLeaf):
    pass  

class ColumnIdentifierNode(ASTLeaf):
    pass


class WhereNode(ASTComposite):
    pass 

class GroupByNode(ASTComposite):
    pass  

class HavingNode(ASTComposite):
    pass  

class OrderByNode(ASTComposite):
    pass 

class OrderByItemNode(ASTComposite):
    pass  

class SortDirectionNode(ASTLeaf):
    pass  

class JoinNode(ASTComposite):
    pass  

class ColumnListNode(ASTComposite):
    pass  

class ValueListNode(ASTComposite):
    pass  

class SetClauseNode(ASTComposite):
    pass 

class AssignmentNode(ASTComposite):
    pass


class ExprNode(ASTComposite):
    pass


class BinaryAndExprNode(ExprNode):
    pass


class BinaryOrExprNode(ExprNode):
    pass

class BinaryAddExprNode(ExprNode):
    pass

class BinarySubExprNode(ExprNode):
    pass

class BinaryDivExprNode(ExprNode):
    pass

class BinaryMulExprNode(ExprNode):
    pass

class SubqueryExprNode(ExprNode):
    def __init__(self, select_node):
        super().__init__()
        self.select = select_node
        self.children = [select_node]

class BinaryComparisonExprNode(ExprNode):
    pass

class IsNullNode(ExprNode):
    def __init__(self, expr, negated=False):
        super().__init__()
        self.add(expr)
        self.negated = negated
    def print(self, indent=0):
        pad = "  " * indent
        label = "IS NOT NULL" if self.negated else "IS NULL"
        print(f"{pad}{label}")
        for child in self.children:
            child.print(indent + 1)
        
    

#  LIKE / NOT LIKE
class LikeNode(ExprNode):
    def __init__(self, left, pattern, negated=False):
        super().__init__()
        self.negated = negated
        self.add(left)
        self.add(pattern)
    def print(self, indent=0):
        pad = "  " * indent
        label = "NOT LIKE" if self.negated else "LIKE"
        print(f"{pad}{label}")
        for child in self.children:
            child.print(indent + 1)
        
    

class InExprNode(ExprNode):
    def __init__(self, left, values, negated=False):
        super().__init__()
        self.add(left)
        for v in values:
            self.add(v)
        self.negated = negated



class BinaryNotEqualExprNode(BinaryComparisonExprNode):
    pass

    
class EXISTS(ExprNode):
    def __init__(self, negated=False):
        super().__init__()
        self.negated = negated

    def print(self, indent=0):
        pad = "  " * indent
        prefix = "NOT " if self.negated else ""
        print(f"{pad}{prefix}EXISTS")
        for child in self.children:
            child.print(indent + 1)



class BinaryNotEqualExprNode(BinaryComparisonExprNode):
    pass

class BinaryEqualExprNode(BinaryComparisonExprNode):
    pass


class BinaryGreaterExprNode(BinaryComparisonExprNode):
    pass


class BinaryLessExprNode(BinaryComparisonExprNode):
    pass


class BinaryGreaterEqualExprNode(BinaryComparisonExprNode):
    pass


class BinaryLessEqualExprNode(BinaryComparisonExprNode):
    pass


class NumberLiteralNode(ASTLeaf):
    pass


class StringLiteralNode(ASTLeaf):
    pass

class LiteralNode(ASTLeaf):
    pass

class FunctionCallNode(ASTComposite):
    pass

class IfNode(ASTComposite):
    def __init__(self):
        super().__init__()   

    def print(self, indent=0):
        pad = "  " * indent
        print(f"{pad}IfNode")
        for child in self.children:
            child.print(indent + 1)


class BlockNode(ASTComposite):
    def __init__(self):
        super().__init__()   

    def print(self, indent=0):
        pad = "  " * indent
        print(f"{pad}BlockNode")
        for child in self.children:
            child.print(indent + 1)

class UseNode(ASTComposite):
    pass                        

class TruncateNode(ASTComposite):
    pass