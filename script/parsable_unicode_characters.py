parsed = []

for i in range(0, 0x110000):
    unicode = chr(i)
    value = f"{unicode}{i}{unicode}"

    try:
        if int(value) == i:
            parsed.append(i)
    except Exception:
        ...

print(parsed)
