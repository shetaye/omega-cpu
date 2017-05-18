main: e~divider.o e~divider_tb.o
	ghdl -r divider_TB --wave=wave.ghw
divider.o: divider.vhdl
	ghdl -a divider.vhdl
divider_TB.o: divider_TB.vhdl
	ghdl -a divider_TB.vhdl
e~divider.o: divider.o
	ghdl -e divider
e~divider_tb.o: divider_TB.o
	ghdl -e divider_tb