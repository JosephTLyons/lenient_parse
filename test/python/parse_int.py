import sys

text = sys.argv[1]
base = int(sys.argv[2])
parsed_int = int(text, base=base)

print(parsed_int, end="")
