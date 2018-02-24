import sys

#Numbers defined
num = ['0','1','2','3','4','5','6','7','8','9','-']
#Operators defined
op = ['+','-','/','*']

class Expr:
	def __init__(self, left, op, right):
		self.left = left
		self.right = right
		self.op = op
		self.priority = {'*':0,'/':1,'+':2,'-':3}[op]
	def eval(self):
		lhs = self.left
		rhs = self.right
		op = self.op
		#If a rhs or lhs is a list, it is a token.  If its a string its a constant.  Anything else and its an expr object
		if(type(lhs) == list):
			lhs = lhs[1]
		elif(type(lhs) == str):
			lhs = int(lhs)
		else:
			lhs = lhs.eval()
		if(type(rhs) == list):
			rhs = rhs[1]
		elif(type(rhs) == str):
			rhs = int(rhs)
		else:
			rhs = rhs.eval()
		#Final returns
		if(op == '+'): return lhs + rhs
		if(op == '-'): return lhs - rhs
		if(op == '*'): return lhs * rhs
		if(op == '/'): return lhs / rhs
	def __str__(self):
		return "expr(%s %s %s)" % (self.left, self.op, self.right)
	def __repr__(self):
		return "expr(%s %s %s)" % (self.left, self.op, self.right)
def error(loc,txt,stage):
	print('Calculator reached an error at %d:%d : %s' % (loc,stage,txt))

#Break string apart into tokens (Number or text token)
def tokenize(line):
	text = line.rstrip()
	tokens = []
	#Iterate until 1 character is left
	while(len(text) > 0):
		token = []
		#If we are on an operator and there is no other operator directly before it (Negatives = Minus)
		if(text[0] in op and tokens[-1:][0][0] != 'OPERATOR'):
			token = ['OPERATOR',text[0]]
			text = text[1:]
			print("Clipped text to %s" % text)
		#If we are on a number)
		elif(text[0] in num):
			#Encapsulate the number
			number = ""
			wasNum = True
			n = 0
			#If a negative is detected offset us by 1
			if(text[0] == '-'):
				number += '-'
				n = 1
			#Iterate until no longer on a number
			while(wasNum):	
				if(n>=len(text) or (text[n] not in num) or (text[n] == '-')):
					wasNum = False
					if(n>=len(text)): n = -1
					print("Stopped encapsulating on character %s on index %d" % (text[n],n))
				else:
					print("Added character %s to capsule from index %d" % (text[n],n)) 
					number += text[n]
					n += 1	
			text = text[len(number):]
			token = ['FACTOR',number]
			print("Encapsulated number %s, clipped text to %s" % (number,text))
		#Parenthesis
		elif(text[0]=='('):
			token = ['LEFTPAREN']
			text = text[1:]
		elif(text[0]==')'):
			token = ['RIGHTPAREN']
			text = text[1:]
		#Unrecognized Token
		else:
			error(0,text,0)
			text = ''
		tokens.append(token)
	return tokens
def generate_ast(tokens):
	#Run through parenthesis
	i = 0
	recording = False
	parenTokens = []
	offset = 0
	start = 0
	#Iterate through list of tokens, not using for because 
	#I change the length of tokens in the loop
	while(i < len(tokens)):
		#First (
		if(tokens[i] == ['LEFTPAREN'] and offset == 0):
			start = i
		#Nested (
		if(tokens[i] == ['LEFTPAREN']):
			recording = True
			offset += 1
		#Nested )
		if(tokens[i] == ['RIGHTPAREN']):
			offset -= 1
		#Last )
		if(tokens[i] == ['RIGHTPAREN'] and offset == 0):
			#Break out contents
			parenTokens = parenTokens[1:]
			recording = False
			print("Parenthesis broken, block made: %s" % parenTokens)
			#Recursively call generate_ast on the contents of the parenthesis
			expr = generate_ast(parenTokens)
			#Cut out the contents and parenthesis
			tokens = tokens[:start] + tokens[i+1:]
			#Offset i from removal of tokens, +2 for parenthesis
			i -= len(parenTokens)+2
			#Add recursive expression back
			tokens.insert(start,expr)
			parenTokens = []
		if(recording):
			parenTokens.append(tokens[i])
		i += 1
	#With parenthesis out of the way, generate expression tokens using priority
	#Assign priorities according to PEMDAS (MDAS)
	for token in tokens:
		if(type(token) == list and token[0] == 'OPERATOR'): token.append({'*':0,'/':1,'+':2,'-':3}[token[1]])
	#Steps: 
	#0: Find highest priority operator, if there is a tie choose nearest to start
	#1: Convert to expression, consume left, right and operator tokens
	#2: Find any other operators, if they exist back to 0
	operatorExists = True
	while operatorExists:
		#0
		indexRecord = []
		priorityRecord = 10
		print("Started stage 0: Finding priorities with %s" % tokens)
		for i in range(len(tokens)):
			if(type(tokens[i]) == list and tokens[i][0] == 'OPERATOR'):
				priority = tokens[i][2]
				if(priority < priorityRecord):
					priorityRecord = priority
					indexRecord = [i]
					print("New index/priority record at: %d:%d" % (i,priorityRecord))
				elif(priority == priorityRecord):
					indexRecord.append(i)
		
		if(type(indexRecord) != int): indexRecord = min(indexRecord)
		#1
		print("Started stage 1: tokens: %s" % tokens)
		lhs = tokens[indexRecord-1]
		rhs = tokens[indexRecord+1]
		print("Generating expression with lhs %s rhs %s and operator %s" % (lhs, rhs, tokens[indexRecord][1]))
		expr = Expr(lhs[1] if type(lhs) == list else lhs,  tokens[indexRecord][1],  rhs[1] if type(rhs) == list else rhs)
		tokens = tokens[:indexRecord-1]+tokens[indexRecord+2:]
		tokens.insert(indexRecord-1,expr)
		#2
		operatorExists = False
		for token in tokens:
			if(type(token) is list and token[0] == 'OPERATOR'): operatorExists = True
		print("Moving on to next operator? %s" % operatorExists)
	#At this point the AST should be contained in 1 node existing in tokens
	return tokens[0]

def evaluate_ast(ast):
	return ast.eval()

for line in sys.stdin:
	#Sanitize
	line = line.replace(' ','')
	#Tokenize
	tokenized = tokenize(line)
	print("Tokenizing complete! Tokens: %s" % tokenized)
	#Generate AST
	AST = generate_ast(tokenized)
	print("AST Generation complete! AST: %s" % str(AST))
	#Evaluate AST
	evaluated = evaluate_ast(AST)
	print("Final result: %d" % evaluated)
