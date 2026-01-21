import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from antlr4 import *
from SQL import SQL
from SQLPARSER import SQLPARSER
from lexer_test import CaseInsensitiveStream
from sqlcompiler.ast_builder import ASTBuilder
from ast_graphviz_exporter import ASTGraphvizExporter

def test_parser(sql_text, show_tree=True, show_tokens=False):
    raw_stream = InputStream(sql_text)

    input_stream = CaseInsensitiveStream(raw_stream)

    lexer = SQL(input_stream)
    token_stream = CommonTokenStream(lexer)

    if show_tokens:
        print("\n=== TOKENS ===")
        token_stream.fill()
        symbolic_names = lexer.symbolicNames
        for i, token in enumerate(token_stream.tokens):
            if token.type != -1:  # Not EOF
                t_type = (
                    symbolic_names[token.type]
                    if token.type < len(symbolic_names)
                    else "UNKNOWN"
                )
                print(f"  {i}: {t_type:<20} '{token.text}'")
        print()
        # Reset token stream for parsing
        token_stream.reset()

    parser = SQLPARSER(token_stream)

    tree = parser.sqlScript()

    num_errors = parser.getNumberOfSyntaxErrors()

    if num_errors > 0:
        print(f"[ERROR] SYNTAX ERRORS: {num_errors}")
        return False
    else:
        print("[SUCCESS] Parse successful!")
        if show_tree:
            print("\n=== PARSE TREE ===")
            print(tree.toStringTree(recog=parser))

        # === AST Phase ===
        print("\n=== SEMANTIC AST ===")
        builder = ASTBuilder()
        ast_list = builder.visit(tree) 

        for i, stmt in enumerate(ast_list):
            print(f"\n-- Statement {i+1} --")
            stmt.print()

        return True


def test_parser_from_file(filename, show_tree=True, show_tokens=False):
    file_stream = FileStream(filename, encoding="utf-8")
    with open(filename, "r", encoding="utf-8") as f:
        sql_content = f.read()
    success = test_parser(sql_content, show_tree=show_tree, show_tokens=show_tokens)
    return success


from parse_tree_exporter import ParseTreeGraphvizExporter


def export_parse_tree_image(sql_text, dot_file="parse_tree.dot"):
  
    raw_stream = InputStream(sql_text)
    input_stream = CaseInsensitiveStream(raw_stream) 
    lexer = SQL(input_stream)
    token_stream = CommonTokenStream(lexer)
    parser = SQLPARSER(token_stream)
    tree = parser.sqlScript()

    if parser.getNumberOfSyntaxErrors() > 0:
        print("[ERROR] Syntax errors – image not generated")
        return

    exporter = ParseTreeGraphvizExporter(parser)
    exporter.export(tree, dot_file)  

    builder = ASTBuilder()
    ast_list = builder.visit(tree)

    exporter = ASTGraphvizExporter()
    for i, ast in enumerate(ast_list):
        exporter.export(ast, f"ast_tree_{i}.dot")


def export_parse_tree_image_from_file(sql_file, dot_file="parse_tree.dot"):
    with open(sql_file, "r", encoding="utf-8") as f:
        sql_text = f.read()

    export_parse_tree_image(sql_text, dot_file)


if __name__ == "__main__":
    test_parser_from_file("src/parser_tests.sql", show_tree=True, show_tokens=True)
    export_parse_tree_image_from_file("src/parser_tests.sql", "parse_tree.dot")
    # test_multiple_queries(test_queries, show_tree=True)
