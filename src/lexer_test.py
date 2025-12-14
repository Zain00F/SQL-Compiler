import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from antlr4 import *
from SQL import SQL

def test_lexer(sql_text):
    input_stream = InputStream(sql_text)
    
    lexer = SQL(input_stream)
    
    token_stream = CommonTokenStream(lexer)
    
    token_stream.fill()
    
    tokens = token_stream.tokens
    
    for token in tokens:
        print(token)

def test_lexer_from_file(filename):
    with open(filename, 'r') as file:
        sql_content = file.read().strip()
    
    if sql_content:
        print(f"SQL from file {filename}:")
        print(sql_content)
        print("\nTokens:")
        test_lexer(sql_content)
    else:
        print(f"File {filename} is empty.")

if __name__ == "__main__":
    sql_query = "SELECT name, age FROM users WHERE age = 25"
    
    print("SQL Query:", sql_query)
    print("\nTokens:")
    test_lexer(sql_query)
    
    print("\n" + "="*50 + "\n")
    
    # Test from file
    test_lexer_from_file("src/tests.sql")

