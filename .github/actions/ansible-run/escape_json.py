#!/usr/bin/env python3
"""
Helper script to escape control characters in JSON strings.
Fixes common issues like unescaped newlines in private keys.
"""
import json
import sys
import re

json_str = sys.stdin.read().strip()

# Handle empty input
if not json_str or json_str == "{}":
    print("{}")
    sys.exit(0)

# Try to parse as-is first
try:
    parsed = json.loads(json_str)
    # If it parses, re-encode it to ensure proper escaping
    print(json.dumps(parsed))
    sys.exit(0)
except json.JSONDecodeError as e:
    # If parsing fails, try to fix unescaped control characters in string values
    # Strategy: manually process the JSON string to escape control chars in string values
    try:
        fixed = json_str
        result = []
        i = 0
        in_string = False
        escape_next = False
        
        while i < len(fixed):
            char = fixed[i]
            
            if escape_next:
                result.append(char)
                escape_next = False
            elif char == '\\':
                result.append(char)
                escape_next = True
            elif char == '"':
                result.append(char)
                in_string = not in_string
            elif in_string:
                # Inside a string - escape control characters
                if char == '\n':
                    result.append('\\n')
                elif char == '\r':
                    result.append('\\r')
                elif char == '\t':
                    result.append('\\t')
                elif char == '\b':
                    result.append('\\b')
                elif char == '\f':
                    result.append('\\f')
                elif ord(char) < 32:  # Other control characters
                    result.append(f'\\u{ord(char):04x}')
                else:
                    result.append(char)
            else:
                result.append(char)
            i += 1
        
        fixed = ''.join(result)
        
        # Try to parse the fixed version
        try:
            parsed = json.loads(fixed)
            print(json.dumps(parsed))
            sys.exit(0)
        except json.JSONDecodeError:
            # If still failing, try ast.literal_eval as fallback
            import ast
            python_str = fixed.replace('true', 'True').replace('false', 'False').replace('null', 'None')
            python_obj = ast.literal_eval(python_str)
            
            def to_json_compatible(obj):
                if isinstance(obj, dict):
                    return {str(k): to_json_compatible(v) for k, v in obj.items()}
                elif isinstance(obj, (list, tuple)):
                    return [to_json_compatible(item) for item in obj]
                elif isinstance(obj, str):
                    return obj
                elif obj is True:
                    return True
                elif obj is False:
                    return False
                elif obj is None:
                    return None
                else:
                    return obj
            
            json_obj = to_json_compatible(python_obj)
            print(json.dumps(json_obj))
            sys.exit(0)
    except Exception as parse_error:
        print(f"Error: Could not parse or fix JSON: {parse_error}", file=sys.stderr)
        print(f"Original JSON error: {e}", file=sys.stderr)
        sys.exit(1)
except Exception as e:
    print(f"Unexpected error processing JSON: {e}", file=sys.stderr)
    sys.exit(1)

