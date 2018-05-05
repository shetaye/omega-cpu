.data
state:	.byte 0,0,0,0
buffer_is_empty:	.byte 0,0,0,0
buffer:	 .byte 0,0,0,0
prevcharacter:	 .byte 0,0,0,0
number:	 .byte 0,0,0,0
gotoLookup:
	.byte 6,0,0,0
	.byte -1,0,0,0
	.byte 7,0,0,0
	.byte -1,0,0,0
	.byte 8,0,0,0
	.byte -1,0,0,0
	.byte -1,0,0,0
	.byte -1,0,0,0
	.byte -1,0,0,0
	.byte -1,0,0,0
	.byte 16,0,0,0
	.byte 17,0,0,0
	.byte 18,0,0,0
	.byte 19,0,0,0
	.byte -1,0,0,0
	.byte -1,0,0,0
	.byte -1,0,0,0
	.byte -1,0,0,0
	.byte -1,0,0,0
	.byte -1,0,0,0
token_is_empty:	.byte 0,0,0,0
token:
	.byte 0,0,0,0
	.byte 0,0,0,0
pState:	.byte 0,0,0,0
element:
	.byte 0,0,0,0
	.byte 0,0,0,0
a:
	.byte 0,0,0,0
	.byte 0,0,0,0
b:
	.byte 0,0,0,0
	.byte 0,0,0,0
accepted:	.byte 0,0,0,0
tType: .byte 0,0,0,0
tVal: .byte 0,0,0,0
sState: .byte 0,0,0,0
.text
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
	EQI $r10,$r9,48
	BZI $r10,nextToken_else1
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
	LTI $r10,$r9,49
	GTI $r11,$r9,58
	OR $r10,$r10,$r11
	BZI $r10,nextToken_else2
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
	EQI $r10,$r9,43
	EQI $r11,$r9,45
	OR $r10,$r10,$r11
	EQI $r11,$r9,42
	OR $r10,$r10,$r11
	EQI $r11,$r9,47
	OR $r10,$r10,$r11
	EQI $r11,$r9,40
	OR $r10,$r10,$r11
	EQI $r11,$r9,41
	OR $r10,$r10,$r11
	BZ $r10,nextToken_else3
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
	EQI $r10,$r9,32
	EQI $r11,$r9,9
	OR $r10,$r10,$r11
	BZI $r10,nextToken_else4
#; state = 1;
	LA $r10,state
	ADDI $r11,$r0,1
	SW $r10,$r11
#; buffer = getchar();
	LA $r10,buffer
	INPB $r11,$p1
	SW $r10,$r11
#; break;
	J nextToken_switchFinished
nextToken_else4:
	EQ $r9, 10
	BZ nextToken_else5
#; buffer_is_empty = 1;
	LA $r10,buffer_is_empty
	ADDI $r11,$r0,1
	SW $r10,$r11
#; p[0] = TOKEN_EOL;
	ADDI $r10,$r0,8
	SW $r4,$r10
#; return;
	RET
nextToken_else5:
#; no EOF, return;
	RET
#; Error:
#; buffer_is_empty = 1;
	LA $r10,buffer_is_empty
	ADDI $r11,$r0,1
	SW $r10,$r11
#; p[0] = TOKEN_ERROR;
	ADDI $r10,$r0,7
	SW $r4,$r10
#; return;
	RET
nextToken_case2:
	LA $r9,buffer
	LW $r9,$r9
	LTI $r10,$r9,48
	GTI $r11,$r9,57
	OR $r10,$r10,$r11
	BNZ $r10,nextToken_else6
#; number = number * 10 + (buffer - '0');
#; number * 10
	LA $r10,number
	LW $r11,$r10
	MULTI $r11,$r11,10
	SW $r10,$r11
#; (buffer - '0')
	LA $r10,buffer
	LW $r10,$r10
	SUBI $r10,$r10,48
#; number = ... + (...);
	LA $r11,number
	LW $r12,$r11
	ADD $r10,$r10,$r12
	SW $r11,$r10
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
nextToken_else6:
#; p[0] = TOKEN_NUMBER;
	ADDI $r10,$r0,0
	SW $r4,$r10
#; p[1] = number;
	LA $r10,number
	LW $r10,$r10
	ADDI $r11,$r4,4
	SW $r11,$r10
#; return;
	RET
#; break; (Why? we just returned!)
	J nextToken_switchFinished
nextToken_case3:
#; state = 1;
	LA $r10,state
	ADDI $r11,$r0,1
	SW $r10,$r11
#; p[0] = TOKEN_NUMBER;
	ADDI $r10,$r0,0
	SW $r4,$r10
#; p[1] = 0;
	ADDI $r11,$r4,4
	SW $r11,$r0
#; return;
	RET
#; break;
	J nextToken_switchFinished
nextToken_case4:
#; state = 1;
	LA $r10,state
	ADDI $r11,$r0,1
	SW $r10,$r11
#; switch statement turned to if statement:
	LA $r10,prevcharacter
	LW $r10,$r10
	EQI $r10,$r10,43
	BZI $r10,nextToken_else7
#; p[0] = TOKEN_PLUS;
	ADDI $r10,$r0,1
	SW $r4,$r10
#; break;
	J nextToken_switch2Finished
nextToken_else7:
	LA $r10,prevcharacter
	LW $r10,$r10
	EQI $r10,$r10,45
	BZI $r10,nextToken_else8
#; p[0] = TOKEN_MINUS;
	ADDI $r10,$r0,2
	SW $r4,$r10
#; break;
	J nextToken_switch2Finished
nextToken_else8:
	LA $r10,prevcharacter
	LW $r10,$r10
	EQI $r10,$r10,47
	BZI $r10,nextToken_else9
#; p[0] = TOKEN_DIV;
	ADDI $r10,$r0,4
	SW $r4,$r10
#; break;
	J nextToken_switch2Finished
nextToken_else9:
	LA $r10,prevcharacter
	LW $r10,$r10
	EQI $r10,$r10,42
	BZI $r10,nextToken_else10
#; p[0] = TOKEN_MULT;
	ADDI $r10,$r0,3
	SW $r4,$r10
#; break;
	J nextToken_switch2Finished
nextToken_else10:
	LA $r10,prevcharacter
	LW $r10,$r10
	EQI $r10,$r10,40
	BZI $r10,nextToken_else11
#; p[0] = TOKEN_LEFTP;
	ADDI $r10,$r0,5
	SW $r4,$r10
#; break;
	J nextToken_switch2Finished
nextToken_else11:
#; p[0] = TOKEN_RIGHTP;
	ADDI $r10,$r0,6
	SW $r4,$r10
nextToken_switch2Finished:
#; p[1] = 0;
	ADDI $r10,$r4,4
	SW $r10,$r0
#; return;
	RET
#; break;
	J nextToken_switchFinished
nextToken_switchFinished:
	LA $r8,state
	LW $r8,$r8
	EQI $r8,$r8,1
	BZI $r8,nextToken_doWhile_stateNot1
#; TODO: Insert reset_stack
push:
	SUBI $r29,$r29,4
	SW $r29,$r4
	SUBI $r29,$r29,4
	SW $r29,$r5
	RET
pop:
	LW $r8,$r29
	SW $r8,$r4
	ADDI $r29,$r29,4
	LW $r8,$r29
	SW $r8,$r5
	ADDI $r29,$r29,4
	RET
#; TODO: Insert read_in_error
main:
#; Initialize state
	LA $r8,state
	ADDI $r9,$r0,1
	SW $r8,$r9
#; Initialize buffer_is_empty
	LA $r8,buffer_is_empty
	ADDI $r9,$r0,1
	SW $r8,$r9
main_do1:
#; if token_is_empty
	LA $r8,token_is_empty
	LW $r9,$r8
	BZI $r9 main_if1
	LA $r4,token
	CALL nextToken
	SW $r8,$r0
main_if1:	
#; tType = token[0];
	LA $r8,tType
	LA $r9,token
	LW $r9,$r9
	SW $r8,$r9
#; tVal = token[1];
	LA $r8,tVal
	LA $r9,token
	ADDI $r9,$r9,4
	LW $r9,$r9
	SW $r8,$r9
#; sState = sp[1];
	LA $r9,sState
	ADD $r8,$r0,$r29
	ADDI $r8,$r8,4
	LW $r8,$r8
	SW $r9,$r8 
#; switch(sState)
	LA $r9,sState
	LA $r8,main_switch1
	LW $r9,$r9
	MULTI $r9,$r9,4
	ADD $r8,$r8,$r9
	J $r8
main_switch1:
	J main_case0
	J main_case1
	J main_case2
	J main_case3
	J main_case4
	J main_case5
	J main_case6
	J main_case7
	J main_case8
	J main_case9
	J main_case10
	J main_case11
	J main_case12
	J main_case13
	J main_case14
	J main_case15
	J main_case16
	J main_case17
main_case0:
#; switch(tType) -> if(tType == TOKEN_NUMBER)
	LA $r9,tType
	LW $r9,$r9
	EQI $r10,$r9,0
	BZI $r10,main_else1
#; a[0] = 1;
	LA $r8,a
	ADDI $r9,$r0,1
	SW $r8,$r9
#; a[1] = tVal;
	LA $r9,tVal
	LA $r9,$r9
	ADDI $r8,$r8,4
	SW $r8,$r9
#; token_is_empty = 1;
	LA $r8,token_is_empty
	ADDI $r9,$r0,1
	SW $r8,$r9
#; break;
	J main_endSwitch2
main_else1:
	EQI $r10,$r9,2
	BZI $r10,main_else2
#; a[0] = 2;
	LA $r8,a
	ADDI $r9,$r0,2
	SW $r8,$r9
#; token_is_empty = 1;
	LA $r8,token_is_empty
	ADDI $r9,$r0,1
	SW $r8,$r9
#; break;
	J main_endSwitch2
main_else2:
	EQI $r10,$r9,8
	BZI $r10,main_else3
#; a[0] = 3
	LA $r8,a
	ADDI $r9,$r0,3
	SW $r8,$r9
#; break;
	J main_endSwitch2
main_else3:
	EQI $r10,$r9,5
	BZI $r10,main_else4
#; a[0] = 4;
	LA $r8,a
	ADDI $r9,$r0,4
	SW $r8,$r9
#; token_is_empty = 1;
	LA $r8,token_is_empty
	ADDI $r9,$r0,1
	SW $r8,$r9
#; break;
	J main_endSwitch2
main_else4:
#; Error
#; TODO: read_in_error();
#; TODO: reset_stack();
#; token_is_empty = 1;
	LA $r8,token_is_empty
	ADDI $r9,$r0,1
	SW $r8,$r9
#; continue
	J main_endSwitch1
main_endSwitch2:
#; push(a);
	LA $r4,a
	CALL push
#; break;
	J main_endSwitch1
main_case2:
main_case4:
main_case10:
main_case11:
main_case12:
main_case13:
#; switch(tType) -> if(tType == TOKEN_NUMBER)
	LA $r8,tType
	LW $r8,$r8
	EQI $r9,$r8,0
	BZI $r9,main_else5
#; a[0] = 1;
	LA $r8,a
	ADDI $r9,$r0,1
	SW $r8,$r9
#; a[1] = tVal;
	LA $r8,a
	LA $r9,tVal
	ADDI $r8,$r8,4
	LW $r9,$r9
	SW $r8,$r9
#; break;
	J main_endSwitch3
main_else5:
	EQI $r9,$r8,2
	BZI $r9,main_else6
#; a[0] = 2;
	LA $r8,a
	ADDI $r9,$r0,2
	SW $r8,$r9
#; break;
	J main_endSwitch3
main_else6:
	EQI $r9,$r8,5
	BZI $r9,main_else7
#; a[0] = 4;
	LA $r8,a
	ADDI $r9,$r0,4
	SW $r8,$r9
#; break;
main_else7:
#; Error
#; TODO: read_in_error();
#; TODO: reset_stack();
#; token_is_empty = 1;
	LA $r8,token_is_empty
	ADDI $r9,$r0,1
	SW $r8,$r9
#; continue
	J main_endSwitch3
main_endSwitch3:
#; push(a)
	LA $r4,a
	CALL push
#; token_is_empty = 1;
	LA $r8,token_is_empty
	ADDI $r9,$r0,1
	SW $r8,$r9
	J main_endSwitch1
main_case3:
#; continue only, no break
#; TODO: reset_stack();
#; token_is_empty = 1;
	LA $r8,token_is_empty
	ADDI $r9,$r0,1
	SW $r8,$r9
#; TODO: if & accepted
#; continue
	J main_endSwitch1
main_case6:
#; switch(tType) -> if(tType == TOKEN_MINUS)
	LA $r8,tType
	LW $r8,$r8
	EQI $r9,$r8,2
	BZI $r9,main_else8
#; a[0] = 10;
	LA $r8,a
	ADDI $r9,$r0,10
	SW $r8,$r9
#; break;
	J main_endSwitch4
main_else8:
	EQI $r9,$r8,1
	BZI $r9,main_else9
#; a[0] = 11;
	LA $r8,a
	ADDI $r9,$r0,11
	SW $r8,$r9
#; break;
	J main_endSwitch4
main_else9:
	EQI $r9,$r8,3
	BZI $r9,main_else10
#; a[0] = 12;
	LA $r8,a
	ADDI $r9,$r0,12
	SW $r8,$r9
#; break;
	J main_endSwitch4
main_else10:
	EQI $r9,$r8,4
	BZI $r9,main_else11
#; a[0] = 13;
	LA $r8,a
	ADDI $r9,$r0,13
	SW $r8,$r9
#; break;
	J main_endSwitch4
main_else11:
	EQI $r9,$r8,8
	BZI $r9,$r0,main_else12
#; pop(b)
	LA $r4,b
	CALL pop
#; printf("%d\n",b[1])
	LA $r9,b
	ADDI $r9,$r9,4
	OUTPB $r9
#; TODO: reset_stack();
#; token_is_empty = 1
	LA $r8,token_is_empty
	ADDI $r9,$r0,1
	SW $r8,$r9
#; continue;
	J main_endSwitch1
main_else12:
#; TODO: read_in_error();
#; TODO: reset_stack();
#; token_is_empty = 1;
	LA $r8,token_is_empty
	ADDI $r9,$r0,1
	SW $r8,$r9
#; continue
	J main_endSwitch1
main_endSwitch4:
#; push(a);
	LA $r4,a
	CALL push
#; token_is_empty = 1;
	LA $r8,token_is_empty
	ADDI $r9,$r0,1
	SW $r8,$r9
main_case8:
#; switch(tType) -> if(tType == TOKEN_MINUS)
	LA $r8,tType
	LW $r8,$r8
	EQI $r9,$r8,2
	BZI $r9,main_else13
#; a[0] = 10;
	LA $r8,a
	ADDI $r9,$r0,10
	SW $r8,$r9
#; break;
	J main_endSwitch5
main_else13:
	EQI $r9,$r8,1
	BZI $r9,main_else14
#; a[0] = 11;
	LA $r8,a
	ADDI $r9,$r0,11
	SW $r8,$r9
#; break;
	J main_endSwitch5
main_else14:
	EQI $r9,$r8,3
	BZI $r9,main_else15
#; a[0] = 12;
	LA $r8,a
	ADDI $r9,$r0,12
	SW $r8,$r9
#; break;
	J main_endSwitch5
main_else15:
	EQI $r9,$r8,4
	BZI $r9,main_else16
#; a[0] = 13;
	LA $r8,a
	ADDI $r9,$r0
	SW $r8,$r9
#; break;
	J main_endSwitch5
main_else16:
	EQI $r9,$r8,6
	BZI $r9,main_else17
#; a[0] = 15;
	LA $r8,a
	ADDI $r9,$r0
	SW $r8,$r9
#; break;
	J main_endSwitch5
main_else17:
#; Error
#; TODO: read_in_error()
#; TODO: reset_stack();
#; token_is_empty = 1;
	LA $r8,token_is_empty
	ADDI $r9,$r0,1
	SW $r8,$r9
#; continue
	J main_endSwitch1
main_endSwitch5:
#; push(a);
	LA $r4,a
	CALL push
#; token_is_empty = 1;
	LA $r8,token_is_empty
	ADDI $r9,$r0,1
	SW $r8,$r9
	J main_endSwitch1
main_case1:
#; pop(b);
	LA $r4,b
	CALL pop
#; b[0] = gotoLookup[sp[1]];
	ADD $r8,$r0,$r29
	ADDI $r8,$r8,4
	LA $r8,$r8
	MULTI $r8,$r8,4
	LA $r9,gotoLookup
	ADD $r8,$r9,$r8
	LA $r9,b
	SW $r9,$r8
#; push(b)
	LA $r4,b
	CALL push
#; break
	J main_endSwitch1
main_case7:
#; pop(b);
	LA $r4,b
	CALL pop
#; sp += 2;
	ADDI $r29,$r29,2
#; b[0] = gotoLookup[sp[1]];
	ADD $r8,$r0,$r29
	ADDI $r8,$r8,4
	LA $r8,$r8
	MULTI $r8,$r8,4
	LA $r9,gotoLookup
	ADD $r8,$r9,$r8
	LA $r9,b
	Sw $r9,$r8
#; b[1] = -b[1];
	LA $r8,b
	ADDI $r8,$r0,4
	MULTI $r9,$r8,-1
	SW $r8,$r9
#; push(b);
	LA $r4,b
	CALL push
#; break;
	J main_endSwitch1
main_case9:
#;Error
main_case5:
main_case14:
main_case9:
#; continue only, no break
	J main_endSwitch1
main_case15:
	J main_endSwitch1
main_case18:
	J main_endSwitch1
main_case19:
	J main_endSwitch1
main_case16:
	J main_endSwitch1
main_case17:

main_endSwitch1: ADD $r0,$r0,$r0
