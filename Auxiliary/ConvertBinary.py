import sys
import re

index = 0

for line in sys.stdin:
    if re.match("[01]{32}\n",line):
        print "Memory(%d) <= \"%s\";" % (index,line[24:32])
        print "Memory(%d) <= \"%s\";" % (index+1,line[16:24])
        print "Memory(%d) <= \"%s\";" % (index+2,line[8:16])
        print "Memory(%d) <= \"%s\";" % (index+3,line[0:8])
        index = index + 4

        
