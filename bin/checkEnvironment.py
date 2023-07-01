import sys
import os
 
virtenv = sys.prefix
desiredenv = sys.argv[1]

print (f"Virtenv: {virtenv}")
print (f"Desired: {desiredenv}")

if virtenv == desiredenv:
    print("\x1b[32mEnvironment is good.\x1b[0m")
    sys.exit(0)
else:
    print("\x1b[33mEnvironment is bad.\x1b[0m")
    if os.path.exists(desiredenv):
        print(f"\x1b[33mEnvironment exists, but is wrong.  We were looking for '{desiredenv}', but found '{virtenv}'.\x1b[0m")
    else:
        print(f"Environment does not exist.   Please create with \x1b[33m'python -m venv {desiredenv}'\x1b[0m")
    sys.exit(1)

