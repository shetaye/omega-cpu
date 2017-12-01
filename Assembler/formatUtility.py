import sys
import re

out = ""
MEMORY_SIZE = 111
n = 0
ins = []
if __name__ == "__main__":
	for a in sys.argv[1:]:
		ins += open(a).readlines()
	for line in ins:
		stripped = line.strip()
		if not stripped: break
		if len(stripped) != 32: break
		out += '"'+stripped[24:32]+'",'
		out += '"'+stripped[16:24]+'",'
		out += '"'+stripped[8:16]+'",'
		out += '"'+stripped[0:8]+'",'
		n += 4
	for i in range(MEMORY_SIZE - n):
		out += '"00000000",'
	out = out[:-1]
	print(out)
