.text

#TODO: Insert nextToken
#TODO: Insert reset_stack

main:
doWhile_nAccepted:
	LA $r1,switch_sState
	LW $r2,$r27
	MULTI $r2,$r2,4
	ADDR $r1,$r1,$r2 
switch_sState:
	J case0
	J case1
	J case2
	J case3
	J case4
	J case5
	J case6
	J case7
	J case8
	J case9
	J case10
	J case11
	J case12
	J case13
	J case14
	J case15
	J case16
	J case17
case0:
	J switch_sState_finished
case2:
case4:
case10:
case11:
case12:
case13:
	J switch_sState_finished
case3:
	# continue only, no break
	J switch_sState_finished
case6:
	J switch_sState_finished
case8:
	J switch_sState_finished
case1:
	J switch_sState_finished
case7:
	J switch_sState_finished
case9: #Error
case5:
case14:
case9:
	# continue only, no break
	J switch_sState_finished
case15:
	J switch_sState_finished
case18:
	J switch_sState_finished
case19:
	J switch_sState_finished
case16:
	J switch_sState_finished
case17:

switch_sState_finished:

