import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from antlr4 import *
from SQL import SQL

def test_lexer(sql_text):
    # Create input stream from SQL text
    input_stream = InputStream(sql_text)
    
    # Create lexer
    lexer = SQL(input_stream)
    
    # Create token stream
    token_stream = CommonTokenStream(lexer)
    
    # Fill token stream with all tokens
    token_stream.fill()
    
    # Get all tokens
    tokens = token_stream.tokens
    
    # Print each token in the required format (including EOF)
    for token in tokens:
        print(token)

def test_lexer_from_file(filename):
    # Read SQL content from file
    with open(filename, 'r') as file:
        sql_content = file.read().strip()
    
    if sql_content:
        print(f"SQL from file {filename}:")
        print(sql_content)
        print("\nTokens:")
        # Use the existing test_lexer method
        test_lexer(sql_content)
    else:
        print(f"File {filename} is empty.")

if __name__ == "__main__":
    # Simple SQL query test
    sql_query = "SELECT name, age FROM users WHERE age = 25"
    
    print("SQL Query:", sql_query)
    print("\nTokens:")
    test_lexer(sql_query)
    
    print("\n" + "="*50 + "\n")
    
    # Test from file
    test_lexer_from_file("src/tests.sql")

