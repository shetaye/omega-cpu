#; This file is part of the Omega CPU Core
#; Copyright 2015 - 2016 Joseph Shetaye 

#; This program is free software: you can redistribute it and/or modify
#; it under the terms of the GNU Lesser General Public License as
#; published by the Free Software Foundation, either version 3 of the
#; License, or (at your option) any later version.

#; This program is distributed in the hope that it will be useful,
#; but WITHOUT ANY WARRANTY; without even the implied warranty of
#; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#; GNU General Public License for more details.

#; You should have received a copy of the GNU General Public License
#; along with this program.  If not, see <http://www.gnu.org/licenses/>.

.text
modePrompt: .asciiz "Encrypt/Decrypt (e/d)?\n"
keyPrompt: .asciiz "Enter Key:\n"
messagePrompt:	.asciiz "Enter Message:\n"
keybuffer: .asciiz "                                                                                                    "
readKey:
	LA $r8,keybuffer
	ADDI $r5,$r0,0
readKey_while1:
	INPB $r4,$p1
	LTI $r1,$r4,65
	BNZI $r1,readKey_nonLetter
	LTI $r1,$r4,91
	BNZI $r1,readKey_uppercase
	LTI $r1,$r4,97
	BNZI $r1,readKey_nonLetter
	LTI $r1,$r4,123
	BNZI $r1,readKey_lowercase
	J readKey_nonLetter
readKey_nonLetter:
	EQI $r1,$r4,10
	BNZI $r1,readKey_end
	J readKey_while1
readKey_uppercase:
	SUBI $r4,$r4,65
	J readKey_if1end
readKey_lowercase:
	SUBI $r4,$r4,97
	J readKey_if1end
readKey_if1end:
	LTI $r1,$r5,100
	BZI $r1,readKey_while1
	ADD $r1,$r5,$r8
	SB $r4,$r1
	ADDI $r5,$r5,1
	J readKey_while1
readKey_end:
	ADDI $r2,$r5,0
	RET

transform:
	LA $r1,keybuffer
	ADD $r1,$r1,$r15
	LB $r5,$r1
	BZI $r17,transform_decrypt
transform_encrypt:
	ADD $r2,$r4,$r5
	ADDI $r6,$r0,26
	DIV $r0,$r2,$r6,$r2
	J transform_end
transform_decrypt:
	ADDI $r6,$r0,26
	ADD $r2,$r6,$r4
	SUB $r2,$r2,$r5
	DIV $r0,$r2,$r6,$r2
	J transform_end
transform_end:
	ADDI $r15,$r15,1
	DIV $r0,$r15,$r16,$r15
	RET
main:
	LA $r4,keyPrompt
	CALL print_string
	CALL readKey
	BZI $r2,main
	ADDI $r16,$r2,0
	
encryptdecrypt_loop:
	LA $r4,modePrompt
	CALL print_string
	INPB $r4,$p1
encryptdecrypt_loop2:	
	INPB $r1,$p1
	EQI $r1,$r1,10
	BZI $r1,encryptdecrypt_loop2
	EQI $r1,$r4,100
	BNZI $r1,encryptdecrypt_d
	EQI $r1,$r4,101
	BNZI $r1,encryptdecrypt_e
	J encryptdecrypt_other
encryptdecrypt_d:
	ADDI $r17,$r0,0
	J encryptdecrypt_end
encryptdecrypt_e:
	ADDI $r17,$r0,1
	J encryptdecrypt_end
encryptdecrypt_other:
	J encryptdecrypt_loop
encryptdecrypt_end:
	ADDI $r15,$r0,0
	LA $r4,messagePrompt
	CALL print_string	
readMessage_loop:
	INPB $r4,$p1
	EQI $r1,$r4,10
	BZI $r1,readMessage_notNewline
	OUTPB $r4,$p1
	J main
readMessage_notNewline:
	LTI $r1,$r4,65
	BNZI $r1,readMessage_nonLetter
	LTI $r1,$r4,91
	BNZI $r1,readMessage_uppercase
	LTI $r1,$r4,97
	BNZI $r1,readMessage_nonLetter
	LTI $r1,$r4,123
	BNZI $r1,readMessage_lowercase
	J readMessage_nonLetter

readMessage_nonLetter:
	OUTPB $r4,$p1
	J readMessage_loop
readMessage_uppercase:
	SUBI $r4,$r4,65
	CALL transform
	ADDI $r2,$r2,65
	OUTPB $r2,$p1
	J readMessage_loop
readMessage_lowercase:
	SUBI $r4,$r4,97
	CALL transform
	ADDI $r2,$r2,97
	OUTPB $r2,$p1
	J readMessage_loop
	
	
	
	