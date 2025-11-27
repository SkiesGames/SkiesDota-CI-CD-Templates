#!/usr/bin/env python3
import json
import sys
import re

s = sys.stdin.read().strip()
if not s or s == "{}":
    print("{}")
    sys.exit(0)

try:
    print(json.dumps(json.loads(s)))
except:
    # Fix unescaped newlines in string values
    result = []
    in_string = False
    escape_next = False
    for char in s:
        if escape_next:
            result.append(char)
            escape_next = False
        elif char == '\\':
            result.append(char)
            escape_next = True
        elif char == '"':
            result.append(char)
            in_string = not in_string
        elif in_string and char == '\n':
            result.append('\\n')
        elif in_string and char == '\r':
            result.append('\\r')
        elif in_string and char == '\t':
            result.append('\\t')
        else:
            result.append(char)
    
    try:
        print(json.dumps(json.loads(''.join(result))))
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

