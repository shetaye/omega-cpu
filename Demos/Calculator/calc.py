import pygame,sys
from pygame.locals import *
from pygame.surface import *
from pygame.display import *
from pygame.event import *

HSIZE = 320
VSIZE = 200

surface = None
lineBuffer = [[]]
charcodes = {
pygame.K_PLUS : "+",
pygame.K_MINUS : "-",
pygame.K_SLASH : "/",
pygame.K_ASTERISK : "*",
pygame.K_LEFTPAREN : "(",
pygame.K_RIGHTPAREN : ")",
pygame.K_0 : "0",
pygame.K_1 : "1",
pygame.K_2 : "2",
pygame.K_3 : "3",
pygame.K_4 : "4",
pygame.K_5 : "5",
pygame.K_6 : "6",
pygame.K_7 : "7",
pygame.K_8 : "8",
pygame.K_9 : "9"}

chars = [24, #00011000 - start 0
	36,  #00100100
	66,  #01000010
	66,  #01000010
	66,  #01000010
	66,  #01000010
	36,  #00100100
	24,  #00011000 - start 1
	24,  #00011000
	40,  #00101000
	8,   #00001000
	8,   #00001000
	8,   #00001000
	8,   #00001000
	8,   #00001000
	126, #01111110
	56,  #00111000 - start 2
	68,  #01000100
	4,   #00000100
	8,   #00001000
	16,  #00010000
	32,  #00100000
	64,  #01000000
	126, #01111110
	56,  #00111000 - start 3
	4,   #00000100
	4,   #00000100
	4,   #00000100
	56,  #00111000
	4,   #00000100
	4,   #00000100
	56,  #00111000
	24,  #00011000 - start 4
	40,  #00101000
	40,  #00101000
	72,  #01001000
	124, #01111100
	8,   #00001000
	8,   #00001000
	8,   #00001000
	60,  #00111100 - start 5
	32,  #00100000 
	32,  #00100000
	56,  #00111000
	4,   #00000100
	4,   #00000100
	68,  #01000100
	56,  #00111000
	12,  #00001100 - start 6
	16,  #00010000
	32,  #00100000
	96,  #01100000
	120, #01111000
	68,  #01000100
	68,  #01000100
	56,  #00111000
	126, #01111110 - start 7
	4,   #00000100
	8,   #00001000
	8,   #00001000
	16,  #00010000
	32,  #00100000
	32,  #00100000
	64,  #01000000
	24,  #00011000 - start 8
	36,  #00100100
	36,  #00100100
	24,  #00011000
	24,  #00011000
	36,  #00100100
	36,  #00100100
	24,  #00011000
	28,  #00011100 - start 9
	34,  #00100010
	34,  #00100010
	34,  #00100010
	30,  #00011110
	4,   #00000100
	8,   #00001000
	48,  #00110000
	24,  #00011000 - start +
	24,  #00011000
	24,  #00011000
	255, #11111111
	255, #11111111
	24,  #00011000
	24,  #00011000
	24,  #00011000
	0,   #00000000 - start -
	0,   #00000000
	0,   #00000000
	255, #11111111
	255, #11111111
	0,   #00000000
	0,   #00000000
	0,   #00000000
	6,   #00000110 - start /
	14,  #00001110
	12,  #00001100
	24,  #00011000
	24,  #00011000
	48,  #00110000
	112, #01110000
	56,  #01100000
	0,   #00000000 - start x
	66,  #01000010
	36,  #00100100
	24,  #00011000
	24,  #00011000
	36,  #00100100
	66,  #01000010
	0,   #00000000
	8,   #00001000 - start (
	16,  #00010000
	32,  #00100000
	64,  #01000000
	64,  #01000000
	32,  #00100000
	16,  #00010000
	8,   #00001000
	16,  #00010000 - start )
	8,   #00001000
	4,   #00000100
	2,   #00000010
	2,   #00000010
	4,   #00000100
	8,   #00001000
	16]  #00010000

def initializeScreen():
	pixelMem.fill((0,0,0))
	pixelMem.set_at((10,10),(255,255,255))
	pygame.display.flip()
def drawCharacter(x,y,c,s):
	charOffsets = {
	'0':0,
	'1':8,
	'2':16,
	'3':24,
	'4':32,
	'5':40,
	'6':48,
	'7':56,
	'8':64,
	'9':72,
	'+':80,
	'-':88,
	'/':94,
	'*':102,
	'(':110,
	')':118}
	for i in range(8):
		for j in range(8):
			rx = i + x
			ry = j + y
			#print(charOffsets[c])
			is_set = (chars[j + charOffsets[c]] << i) & 128
			if(is_set == 128 and rx >= 0 and rx <= HSIZE and ry >= 0 and ry <= VSIZE):
				s.set_at((rx,ry),(255,255,255))
def redraw(s):
	s.fill((0,0,0))
	global lineBuffer
	row = 0
	for line in lineBuffer:
		column = 0
		for char in line:
			print(str(row)+':'+str(column))
			drawCharacter(column,row,char,s)
			column += 8
		row += 8
	pygame.display.flip()
def keyInterrupt(e,s):
	global lineBuffer
	#drawCharacter(10,10,'c',s)
	print(pygame.key.get_pressed().index(1))
	if(e.key == pygame.K_q):
		pygame.quit()
		sys.exit("Quit")
	try:
		if(e.key == pygame.K_RETURN):
			newBuffer = [[]]
			for i in lineBuffer:
				newBuffer.append(i)
			lineBuffer = newBuffer
			redraw(s)
			print('return')
		elif(e.key == 304):
			pass
		else:
			keys = pygame.key.get_pressed()
			shift = keys[pygame.K_LSHIFT]
			char = ''
			if(keys.index(1)==52 and shift): char = '('
			elif(keys.index(1)==48 and shift): char = ')'
			else: char = charcodes[e.key]
			#Valid Character
			print(shift)
			lineBuffer[0].append(char)
			#drawCharacter(0,0,charcodes[e.key],s)
			redraw(s)
	except:
		raise	
if __name__ == '__main__':
	pygame.init()
	surface = pygame.display.set_mode((HSIZE,VSIZE))
	surface.fill((0,0,0))
	while True:
		e = pygame.event.wait()
		if(e.type == 2):
			keyInterrupt(e,surface)
		#expr = getExpression()
		#scroll()
		#evaluatedExpr = evaluateExpression(expr)
		#drawText(evaluatedExpr)
		#updateFrame()


