import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from antlr4 import *
from SQL import SQL
class CaseInsensitiveStream:
    def __init__(self, stream):
        self._stream = stream
    def LA(self, i):
        result = self._stream.LA(i)
        if result <= 0:
            return result
        # This converts the character to uppercase for the Lexer's comparison logic
        # without changing the actual text of the token.
        return ord(chr(result).upper())

    def __getattr__(self, name):
        return getattr(self._stream, name)

def test_lexer(sql_text):
    raw_stream = InputStream(sql_text)
    
    input_stream = CaseInsensitiveStream(raw_stream)
    
    # lexer = SQL(input_stream)
    lexer = SQL(raw_stream)
    
    symbolic_names = lexer.symbolicNames
    token_stream = CommonTokenStream(lexer)
    token_stream.fill()
    
    header = f"{'Index':<6} | {'Line:Col':<10} | {'Type':<20} | {'Text':<30}"
    print("-" * len(header))
    print(header)
    print("-" * len(header))
    
    for i, token in enumerate(token_stream.tokens):
        t_type = symbolic_names[token.type] if token.type != -1 else "EOF"
        pos = f"{token.line}:{token.column}"
        t_text = token.text.replace('\n', '\\n').replace('\r', '\\r')
        print(f"{i:<6} | {pos:<10} | {t_type:<20} | {t_text:<30}")
    print("-" * len(header))

def test_lexer_from_file(filename):
    raw_file_stream = FileStream(filename, encoding='utf-8')
    
    input_stream = CaseInsensitiveStream(raw_file_stream)
    
    print(f"SQL from file {filename}:")
    print("\nTokens:")
    
    # 3. Modify test_lexer slightly or call logic directly
    lexer = SQL(input_stream)
    display_tokens(lexer)

def display_tokens(lexer):
    symbolic_names = lexer.symbolicNames
    token_stream = CommonTokenStream(lexer)
    token_stream.fill()
    header = f"{'Index':<6} | {'Line:Col':<10} | {'Type':<20} | {'Text':<30}"
    print("-" * len(header))
    print(header)
    print("-" * len(header))
    for i, token in enumerate(token_stream.tokens):
        t_type = symbolic_names[token.type] if token.type != -1 else "EOF"
        pos = f"{token.line}:{token.column}"
        t_text = token.text.replace('\n', '\\n').replace('\r', '\\r')
        print(f"{i:<6} | {pos:<10} | {t_type:<20} | {t_text:<30}")
    print("-" * len(header))

if __name__ == "__main__":
    # Test lowercase string
    # sql_query = "select name, AGE from users where age = 25"
    # print("SQL Query:", sql_query)
    # test_lexer(sql_query)
    test_lexer_from_file("src/tests.sql")