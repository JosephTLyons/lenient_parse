import json
import sys

json_data = sys.argv[1]
data_list = json.loads(json_data)
output_values = []

for item in data_list:
    input = item["input"]
    base = int(item["base"])

    try:
        value = int(input, base=base)
    except ValueError as e:
        value = f"ValueError: {e}"

    output_values.append(str(value))

json_output = json.dumps(output_values)

print(json_output, end="")
