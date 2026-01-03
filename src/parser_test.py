import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from antlr4 import *
from SQL import SQL  
from SQLPARSER import SQLPARSER  

def test_parser(sql_text, show_tree=True, show_tokens=False):
    input_stream = InputStream(sql_text)
    
    lexer = SQL(input_stream)
    token_stream = CommonTokenStream(lexer)
    
    if show_tokens:
        print("\n=== TOKENS ===")
        token_stream.fill()
        symbolic_names = lexer.symbolicNames
        for i, token in enumerate(token_stream.tokens):
            if token.type != -1:  # Not EOF
                t_type = symbolic_names[token.type] if token.type < len(symbolic_names) else "UNKNOWN"
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
        return True

def test_parser_from_file(filename, show_tree=True, show_tokens=False):
    file_stream = FileStream(filename, encoding='utf-8')
    with open(filename, 'r', encoding='utf-8') as f:
        sql_content = f.read()
    success = test_parser(sql_content, show_tree=show_tree, show_tokens=show_tokens)
    return success


if __name__ == "__main__":
    test_parser_from_file("src/parser_tests.sql", show_tree=True, show_tokens=True)
    
    # test_multiple_queries(test_queries, show_tree=True)