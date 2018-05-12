import sys
import re

out = ""
MEMORY_SIZE = 9000
n = 0
ins = []
k = 0
if __name__ == "__main__":
	for a in sys.argv[1:]:
		ins += open(a).readlines()
	for line in ins:
		k += 1
		stripped = line.strip()
		if not stripped: break
		if len(stripped) != 32: break
		out += '"'+stripped[24:32]+'",'
		out += '"'+stripped[16:24]+'",'
		out += '"'+stripped[8:16]+'",'
		out += '"'+stripped[0:8]+'",'
		n += 4
		if (k % 4) == 3:
			out += '\n'
	for i in range(MEMORY_SIZE - n):
		k += 1
		out += '"00000000",'
		if (k % 4) == 3:
			out += '\n'
	out = out[:-2]
	print(out)
