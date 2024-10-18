import sys

value = sys.argv[1]
parsed_value = int(value) or float(value)
print(parsed_value, end="")
