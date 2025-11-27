#!/usr/bin/env python3
import json
import sys
import ast

s = sys.stdin.read().strip()
if not s or s == "{}":
    print("{}")
    sys.exit(0)

try:
    print(json.dumps(json.loads(s)))
except:
    try:
        obj = ast.literal_eval(s.replace('true', 'True').replace('false', 'False').replace('null', 'None'))
        print(json.dumps(obj, default=str))
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

