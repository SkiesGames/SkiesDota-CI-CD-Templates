#!/usr/bin/env python3
"""
Helper script to escape control characters in JSON strings.
Fixes common issues like unescaped newlines in private keys.
"""
import json
import sys

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
    # If parsing fails, try to use ast.literal_eval to parse as Python literal
    # This is more lenient with control characters, then we re-encode as proper JSON
    try:
        import ast
        # Replace JSON-specific literals with Python equivalents
        python_str = json_str.replace('true', 'True').replace('false', 'False').replace('null', 'None')
        # Parse as Python literal (handles strings with newlines better)
        python_obj = ast.literal_eval(python_str)
        
        # Recursively convert Python types to JSON-compatible types
        def to_json_compatible(obj):
            if isinstance(obj, dict):
                return {str(k): to_json_compatible(v) for k, v in obj.items()}
            elif isinstance(obj, (list, tuple)):
                return [to_json_compatible(item) for item in obj]
            elif isinstance(obj, str):
                return obj  # Strings will be properly escaped by json.dumps
            elif obj is True:
                return True
            elif obj is False:
                return False
            elif obj is None:
                return None
            else:
                return obj
        
        json_obj = to_json_compatible(python_obj)
        # Now encode as proper JSON (this will escape all control characters)
        print(json.dumps(json_obj))
        sys.exit(0)
    except Exception as parse_error:
        print(f"Error: Could not parse or fix JSON: {parse_error}", file=sys.stderr)
        print(f"Original JSON error: {e}", file=sys.stderr)
        print("Please ensure your JSON is valid. For private keys with newlines,", file=sys.stderr)
        print("the action will attempt to auto-escape them, but the JSON structure must be correct.", file=sys.stderr)
        sys.exit(1)
except Exception as e:
    print(f"Unexpected error processing JSON: {e}", file=sys.stderr)
    sys.exit(1)

