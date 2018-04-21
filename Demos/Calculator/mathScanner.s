.data
state:	.byte 0,0,0,0
buffer_is_empty:	.byte 0,0,0,0
buffer:	 .byte 0,0,0,0
prevcharacter:	 .byte 0,0,0,0
number:	 .byte 0,0,0,0
.text

#; TODO: Insert nextToken
nextToken:
	LA $r8,buffer_is_empty
	LW $r9,$r8
	BZI $r8,nextToken_doWhile_stateNot1
	ADDI $r9,$r0,0
	SW $r9,$r8
nextToken_doWhile_stateNot1:
	LA $r8,state
	LW $r8,$r8
	LA $r9,nextToken_switch_state
	MULTI $r8,$r8,4
	ADD $r9,$r9,$r8
	JR $r9
nextToken_switch_state:
	J nextToken_case0
	J nextToken_case1
	J nextToken_case2
	J nextToken_case3
	J nextToken_case4
nextToken_case0:
	J nextToken_switchFinished
nextToken_case1:
	LA $r8,buffer
	LW $r9,$r8
	EQI $r9,48
	BZ nextToken_else1
#; state = 3;
	LA $r10,state
	ADDI $r11,$r0,3
	SW $r10,$r11
#; number = 0;
	LA $r10,number
	ADDI $r11,$r0,0
	SW $r10,$r11
#; prevcharacter = buffer;
	LA $r10,buffer
	LW $r10,$r10
	LA $r11,prevcharacter
	SW $r11,$r10
#; break;
	J nextToken_switchFinished
nextToken_else1:
	ADD $r10,$r0,$r9
	ADD $r11,$r0,$r9
	LTI $r10,49
	GTI $r11,58
	OR $r10,$r10,$r11
	BZ nextToken_else2
#; state = 2;
	LA $r10,state
	LW $r11,$r10
	ADDI $r11,$r0,2
	SW $r10,$r11
#; number = buffer - 10;
	LA $r10,buffer
	LW $r11,$r10
	LA $r10,number
	SUBI $r11,$r11,48
	SW $r10,$r11
#; prevcharacter = buffer;
	LA $r10,buffer
	LW $r10,$r10
	LA $r11,prevcharacter
	SW $r11,$r10	
#; buffer = getchar();
	LA $r10,buffer
	INPB $r11,$p1
	SW $r10,$r11
#; break;
	J nextToken_switchFinished
nextToken_else2:
	ADD $r10,$r0,$r9
	EQI $r10,43
	EQI $r11,45
	OR $r10,$r10,$r11
	EQI $r11,42
	OR $r10,$r10,$r11
	EQI $r11,47
	OR $r10,$r10,$r11
	EQI $r11,40
	OR $r10,$r10,$r11
	EQI $r11,41
	OR $r10,$r10,$r11
	BZ nextToken_else3
#; state = 4;
	LA $r10,state
	ADDI $r11,$r0,4
	SW $r10,$r11
#; prevcharacter = buffer;
	LA $r10,buffer
	LW $r10,$r10
	LA $r11,prevcharacter
	SW $r11,$r10
#; buffer = getchar();
	LA $r10,buffer
	INPB $r11,$p1
	SW $r10,$r11
#; break;
	J nextToken_switchFinished
nextToken_else3:
	ADD $r10,$r0,$r9
	EQI $r10,32
	EQI $r11,9
	OR $r10,$r10,$r11
	BZ nextToken_else4
	
nextToken_else4:
	EQ $r9, 10
	BZ nextToken_else5
	
nextToken_else5:
#; No EOF
	ret
nextToken_case2:
	J nextToken_switchFinished
nextToken_case3:
	J nextToken_switchFinished
nextToken_case4:
	J nextToken_switchFinished
nextToken_switchFinished:
	LA $r8,state
	LW $r8,$r8
	SUBI $r8,$r8,1
	BNZI $r8,nextToken_doWhile_stateNot1
#; TODO: Insert reset_stack
#; TODO: Insert push
#; TODO: Insert pop

main:
doWhile_nAccepted:
	LA $r8,switch_sState
	LW $r9,$r27
	MULTI $r9,$r9,4
	ADD $r8,$r8,$r9
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
#; continue only, no break
	J switch_sState_finished
case6:
	J switch_sState_finished
case8:
	J switch_sState_finished
case1:
	J switch_sState_finished
case7:
	J switch_sState_finished
case9:
#;Error
case5:
case14:
case9:
#; continue only, no break
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

switch_sState_finished: ADD $r0,$r0,$r0