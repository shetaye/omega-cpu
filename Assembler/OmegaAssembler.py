# This file is part of the Omega CPU Core
# Copyright 2015 - 2016 Joseph Shetaye

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import sys
import re

OPCODES = { "AND" : (0,2),
          "ANDI" : (0,3),
          "OR" : (0,0),
          "ORI" : (0,1),
          "XOR" : (0,4),
          "XORI" : (0,5),
          "ADD" : (1,0),
          "ADDI" : (1,1),
          "SUB" : (1,2),
          "SUBI" : (1,3),
          "MULT" : (1,4),
          "MULTI" : (1,5),
          "DIV" : (1,6),
          "DIVU" : (1,6),
          "DIVI" : (1,7),
          "SRLV" : (2,2),
          "SRL" : (2,3),
          "SRAV" : (2,0),
          "SRA" : (2,1),
          "SLLV" : (2,4),
          "SLL" : (2,5),
          "LTU" : (3,6),
          "LTUI" : (3,7),
          "LT" : (3,4),
          "LTI" : (3,5),
          "EQ" : (3,0),
          "EQUI" : (3,3),
          "EQI" : (3,1),
          "LBU" : (4,0),
          "LB" : (4,1),
          "LHU" : (4,2),
          "LH" : (4,3),
          "LW" : (4,4),
          "SB" : (4,5),
          "SH" : (4,6),
          "SW" : (4,7),
          "INPBU" : (5,0),
          "INPB" : (5,1),
          "INPHU" : (5,2),
          "INPH" : (5,3),
          "INP" : (5,4),
          "OUTPB" : (5,5),
          "OUTPH" : (5,6),
          "OUTP" : (5,7),
          "JR" : (6,0),
          "JA" : (6,1),
          "J" : (6,2),
          "BZ" : (6,3),
          "BZI" : (6,4),
          "BNZ" : (6,5),
          "BNZI" : (6,6),
          "LA" : (None,None)}

FORMS = { "AND" : 1,
          "ANDI" : 2,
          "OR" : 1,
          "ORI" : 2,
          "XOR" : 1,
          "XORI" : 2,
          "ADD" : 1,
          "ADDI" : 2,
          "SUB" : 1,
          "SUBI" : 2,
          "MULT" : 3,
          "MULTI" : 2,
          "DIV" : 3,
          "DIVU" : 3,
          "DIVI" : 2,
          "SRLV" : 1,
          "SRL" : 2,
          "SRAV" : 1,
          "SRA" : 2,
          "SLLV" : 1,
          "SLL" : 2,
          "LTU" : 1,
          "LTUI" : 2,
          "LT" : 1,
          "LTI" : 2,
          "EQ" : 1,
          "EQUI" : 2,
          "EQI" : 2,
          "LBU" : 8,
          "LB" : 8,
          "LHU" : 8,
          "LH" : 8,
          "LW" : 8,
          "SB" : 8,
          "SH" : 8,
          "SW" : 8,
          "INPBU" : 9,
          "INPB" : 9,
          "INPHU" : 9,
          "INPH" : 9,
          "INP" : 9,
          "OUTPB" : 9,
          "OUTPH" : 9,
          "OUTP" : 9,
          "JR" : 5,
          "JA" : 6,
          "J" : 6,
          "BZ" : 4,
          "BZI" : 7,
          "BNZ" : 4,
          "BNZI" : 7,
          "LA" : 10,
          "CALL" : 11,
          "RET" : 12}

IS_RELATIVE = { "JR" : False,
                "JA" : False,
                "J" : True,
                "BZ" : False,
                "BZI" : True,
                "BNZ" : False,
                "BNZI" : True}

def printError(lineNumber,error,line=[]):
    print >> sys.stderr,"Line: %d (%s), Error %s" % (lineNumber+1," ".join(line),error)

#### Operands ###

class RegisterReference(object):
    def __init__(self,registerNumber):
        self.registerNumber = registerNumber
    def acceptVisitor(self, visitor, parameters = []):
        return visitor.visitRegisterReference(self,parameters)

class Immediate(object):
    def __init__(self,immediate):
        self.immediate = immediate
    def acceptVisitor(self, visitor, parameters = []):
        return visitor.visitImmediate(self,parameters)

class LabelReference(object):
    def __init__(self,label):
        self.label = label
    def acceptVisitor(self, visitor, parameters = []):
        return visitor.visitLabelReference(self,parameters)

class PortReference(object):
        def __init__(self,port):
            self.port = port
        def acceptVisitor(self, visitor, parameters = []):
            return visitor.visitPortReference(self,parameters)

def parseOperand(inputstr):
    if re.match("\\$r[0-9][0-9]?", inputstr):
        registerNumber = int(inputstr[2:])
        if registerNumber not in range(32):
            return None
        return RegisterReference(registerNumber)
    elif re.match("[-]?(0|[1-9][0-9]*)",inputstr):
        immediate = int(inputstr)
        return Immediate(immediate)
    elif re.match("[A-Za-z_][A-Za-z_.0-9]*",inputstr):
        label = inputstr
        return LabelReference(label)
    elif re.match("\\$p[0-9][0-9]?", inputstr):
        portNumber = int(inputstr[2:])
        if portNumber not in range(32):
            return None
        return PortReference(portNumber)

class MachineData(object):
    def __init__(self,address = 0,byte0 = 0,byte1 = 0,byte2 = 0,byte3 = 0):
        self.address = address
        self.bytes = [byte0,byte1,byte2,byte3]
    def acceptVisitor(self, visitor, parameters = []):
        visitor.visitMachineData(self, parameters)

class MachineWord(object):
    def __init__(self,address = 0, opcode = 0,operator = 0,registerA = 0, registerB = 0, registerC = 0, registerD = 0, port = 0, immediateValue = 0, immediateAddressConditional = 0, immediateAddress = 0, signedBit = 0):
        self.address = address
        self.opcode = opcode
        self.operator = operator
        self.registerA = registerA
        self.registerB = registerB
        self.registerC = registerC
        self.registerD = registerD
        self.port = port
        self.immediateValue = immediateValue
        self.immediateAddressConditional = immediateAddressConditional
        self.immediateAddress = immediateAddress
        self.signedBit = signedBit

    def acceptVisitor(self, visitor, parameters = []):
        visitor.visitMachineWord(self, parameters)

    def toNumber(self):
        number = 0
        number = number | (self.opcode << 29)
        number = number | (self.operator << 26)
        number = number | (self.registerA << 21)
        number = number | (self.registerB << 16)
        number = number | (self.registerC << 11)
        number = number | (self.registerD << 6)
        number = number | (self.port << 16)
        number = number | (self.immediateValue & 0xFFFF)
        number = number | ((self.immediateAddressConditional >> 2) & 0x1FFFFF)
        number = number | ((self.immediateAddress >> 2) & 0x3FFFFFF)
        number = number | (self.signedBit & 1)
        return number
         

class TextOutputVisitor(object):
    def __init__(self, fileObject):
        self.fileObject = fileObject

    def visitMachineWord(self, ref, parameters = []):
        self.fileObject.write(format(ref.toNumber(),'032b'))
        self.fileObject.write('\n')

    def visitMachineData(self, ref, parameters = []):
        self.fileObject.write(format(ref.bytes[3],'08b'))
        self.fileObject.write(format(ref.bytes[2],'08b'))
        self.fileObject.write(format(ref.bytes[1],'08b'))
        self.fileObject.write(format(ref.bytes[0],'08b'))
        self.fileObject.write('\n')
    
    def outputBlank(self):
        self.fileObject.write('00000000000000000000000000000000')
        self.fileObject.write('\n')
        
# ##################
# ####Visitor#######
# class AddressAssignmentVisitor(object):
#     def visitRegisterReference(self, registerReference, parameters = []):
#         #Visit Register Reference
#         pass
#     def visitImmediate(self, immediate, parameters = []):
#         #Visit Immediate Code Here
#         pass
#     def visitLabelReference(self, labelReference, parameters = []):
#         #Visit Label Reference
#         pass
#     def visitPortReference(self, portReference, parameters = []):
#         #Visit Port References
#         pass
#     def visitDirective(self, directive, parameters = []):
#         #Visit Directive
#         pass
#     def visitAsciiz(self, asciiz, parameters = []):
#         #Visit Asciiz
#         pass
#     def visitByte(self, byte, parameters = []):
#         #Visit Byte
#         pass
#     def visitDataSegment(self, dataSegment, parameters = []):
#         #Visit Data Segment
#         pass
#     def visitTextSegment(self, textSegment, parameters = []):
#         #Visit Text Segment
#         pass
#     def visitInstruction(self, instruction, parameters = []):
#         #Visit Instruction
#         pass
#     def visitMachineInstruction(self, machineInstruction, parameters = []):
#         #Visit Machine Instruciton
#         pass
#     def visitThreeRegisterMachineInstruction(self, ref, parameters = []):
#         #Visit Three Register Machine Instruction
#         pass
#     def visitTwoRegisterImmediateMachineInstruction(self, ref,parameters = []):
#         #Visit Two Register Immediate Machine Instruction
#         pass
#     def visitFourRegisterMachineInstruction(self, ref, parameters = []):
#         #Visit Four Register Machine Instruction
#         pass
#     def visitTwoRegisterMachineInstruction(self, ref, parameters = []):
#         #Visit Two Register Machine Instruction
#         pass
#     def visitOneRegisterMachineInstruction(self, ref, parameters = []):
#         #Visit One Register Machine Instruction
#         pass
#     def visitImmediateMachineInstruction(self, ref, parameters = []):
#         #Visit Immediate Machine Instruciton
#         pass
#     def visitOneRegisterImmediateMachineInstruction(self, ref, parameters = []):
#         #Visit One Register Immediate Machine Instruction
#         pass
#     def visitOneRegisterOnePortMachineInstruction(self, ref, parameters = []):
#         #Visit One Register One Port Machine Instruction
#         pass
#     def visitLoadAddressPseudoInstruction(self, ref, parameters = []):
#         #Visit Load Addresss Pseudo Instruction
#         pass

####Visitor#######

class MachineObjectBuilder(object):
    def __init__(self, labelBindings, instructionAddresses):
        self.labelBindings = labelBindings
        self.instructionAddresses = instructionAddresses
        self.machineCode = {}
    def visitRegisterReference(self, registerReference, parameters = []):
        #Visit Register Reference
        return registerReference.registerNumber
    def visitImmediate(self, immediate, parameters = []):
        #Visit Immediate Code Here
        return immediate.immediate
    def visitLabelReference(self, labelReference, parameters = []):
        #Visit Label Reference
        if len(parameters) == 1 and hasattr(parameters[0],"opcode") and IS_RELATIVE[parameters[0].opcode]:
            return self.instructionAddresses[self.labelBindings[labelReference.label]] - self.instructionAddresses[parameters[0]]
        elif len(parameters) == 2 and parameters[0] in IS_RELATIVE and IS_RELATIVE[parameters[0]]:
            return self.instructionAddresses[self.labelBindings[labelReference.label]] - parameters[1]
        else:
            return self.instructionAddresses[self.labelBindings[labelReference.label]]
    def visitPortReference(self, portReference, parameters = []):
        #Visit Port References
        return portReference.port
    def visitDirective(self, directive, parameters = []):
        #Visit Directive
        pass
    def visitAsciiz(self, asciiz, parameters = []):
        #Visit Asciiz
        stringBytes = bytearray(asciiz.string)
        byteBuffer = []
        for i in range(len(stringBytes)):
            byteBuffer.append(stringBytes[i])
            if len(byteBuffer) == 4:
                self.machineCode[self.instructionAddresses[asciiz] + (i/4)*4] = MachineData(*([self.instructionAddresses[asciiz]] + byteBuffer))
                byteBuffer = []
        if byteBuffer != []:
            byteBuffer = byteBuffer + [0]*(4-len(byteBuffer))
            self.machineCode[self.instructionAddresses[asciiz] + (len(stringBytes)/4)*4] = MachineData(*([self.instructionAddresses[asciiz]] + byteBuffer))
    def visitByte(self, byte, parameters = []):
        #Visit Byte
        byteBuffer = []
        for i in range(len(byte.bytes)):
            byteBuffer.append(byte.bytes[i])
            if len(byteBuffer) == 4:
                self.machineCode[self.instructionAddresses[byte] + (i/4)*4] = MachineData(*([self.instructionAddresses[byte]] + byteBuffer))
                byteBuffer = []
        if byteBuffer != []:
            byteBuffer = byteBuffer + [0]*(4-len(byteBuffer))
            self.machineCode[self.instructionAddresses[byte] + (len(byte.bytes)/4)*4] = MachineData(*([self.instructionAddresses[byte]] + byteBuffer))
    def visitDataSegment(self, dataSegment, parameters = []):
        #Visit Data Segment
        pass
    def visitTextSegment(self, textSegment, parameters = []):
        #Visit Text Segment
        pass
    def visitInstruction(self, instruction, parameters = []):
        #Visit Instruction
        pass
    def visitMachineInstruction(self, machineInstruction, parameters = []):
        #Visit Machine Instruciton
        pass
    def visitThreeRegisterMachineInstruction(self, ref, parameters = []):
        #Visit Three Register Machine Instruction
        (opcode,operator) = OPCODES[ref.opcode]
        self.machineCode[self.instructionAddresses[ref]] = MachineWord(address = self.instructionAddresses[ref], opcode = opcode, operator = operator, registerA = ref.registerA.acceptVisitor(self), registerB = ref.registerB.acceptVisitor(self), registerC = ref.registerC.acceptVisitor(self))
    def visitTwoRegisterImmediateMachineInstruction(self, ref,parameters = []):
        #Visit Two Register Immediate Machine Instruction
        (opcode,operator) = OPCODES[ref.opcode]
        self.machineCode[self.instructionAddresses[ref]] = MachineWord(address = self.instructionAddresses[ref], opcode = opcode, operator = operator, registerA = ref.registerA.acceptVisitor(self), registerB = ref.registerB.acceptVisitor(self), immediateValue = ref.immediate.acceptVisitor(self))
    def visitFourRegisterMachineInstruction(self, ref, parameters = []):
        #Visit Four Register Machine Instruction
        (opcode,operator) = OPCODES[ref.opcode]
        self.machineCode[self.instructionAddresses[ref]] = MachineWord(address = self.instructionAddresses[ref], opcode = opcode, operator = operator, registerA = ref.registerA.acceptVisitor(self), registerB = ref.registerB.acceptVisitor(self), registerC = ref.registerC.acceptVisitor(self), registerD = ref.registerD.acceptVisitor(self), signedBit = 1 if ref.opcode == "DIVU" else 0)
    def visitTwoRegisterMachineInstruction(self, ref, parameters = []):
        #Visit Two Register Machine Instruction
        (opcode,operator) = OPCODES[ref.opcode]
        self.machineCode[self.instructionAddresses[ref]] = MachineWord(address = self.instructionAddresses[ref], opcode = opcode, operator = operator, registerA = ref.registerA.acceptVisitor(self), registerB = ref.registerB.acceptVisitor(self))
    def visitOneRegisterMachineInstruction(self, ref, parameters = []):
        #Visit One Register Machine Instruction
        (opcode,operator) = OPCODES[ref.opcode]
        self.machineCode[self.instructionAddresses[ref]] = MachineWord(address = self.instructionAddresses[ref], opcode = opcode, operator = operator, registerB = ref.registerB.acceptVisitor(self))
    def visitImmediateMachineInstruction(self, ref, parameters = []):
        #Visit Immediate Machine Instruction
        (opcode,operator) = OPCODES[ref.opcode]
        self.machineCode[self.instructionAddresses[ref]] = MachineWord(address = self.instructionAddresses[ref], opcode = opcode, operator = operator, immediateAddress = ref.immediate.acceptVisitor(self,parameters=[ref]))
    def visitOneRegisterImmediateMachineInstruction(self, ref, parameters = []):
        #Visit One Register Immediate Machine Instruction
        (opcode,operator) = OPCODES[ref.opcode]
        self.machineCode[self.instructionAddresses[ref]] = MachineWord(address = self.instructionAddresses[ref], opcode = opcode, operator = operator, registerA = ref.registerA.acceptVisitor(self), immediateAddressConditional = ref.immediate.acceptVisitor(self,parameters=[ref]))
    def visitOneRegisterOnePortMachineInstruction(self, ref, parameters = []):
        #Visit One Register One Port Machine Instruction
        (opcode,operator) = OPCODES[ref.opcode]
        self.machineCode[self.instructionAddresses[ref]] = MachineWord(address = self.instructionAddresses[ref], opcode = opcode, operator = operator, registerA = ref.registerA.acceptVisitor(self), port = ref.port.acceptVisitor(self))
    def visitLoadAddressPseudoInstruction(self, ref, parameters = []):
        #Visit Load Addresss Pseudo Instruction
        (ADDI_Opcode,ADDI_Operator) = OPCODES["ADDI"]
        (SLL_Opcode,SLL_Operator) = OPCODES["SLL"]
        address = ref.labelReference.acceptVisitor(self)
        byte3 = (address & 0xFF000000) >> 24     
        byte2 = (address & 0x00FF0000) >> 16     
        byte1 = (address & 0x0000FF00) >> 8       
        byte0 = (address & 0x000000FF)
        self.machineCode[self.instructionAddresses[ref]] = MachineWord(address = self.instructionAddresses[ref], opcode = ADDI_Opcode, operator = ADDI_Operator, registerA = ref.registerA.acceptVisitor(self), registerB = 0, immediateValue =  byte3)
        self.machineCode[self.instructionAddresses[ref]+4] = MachineWord(address = self.instructionAddresses[ref]+4, opcode = SLL_Opcode, operator = SLL_Operator, registerA = ref.registerA.acceptVisitor(self), registerB = ref.registerA.acceptVisitor(self), immediateValue = 8)
        self.machineCode[self.instructionAddresses[ref]+8] = MachineWord(address = self.instructionAddresses[ref]+8, opcode = ADDI_Opcode, operator = ADDI_Operator, registerA = ref.registerA.acceptVisitor(self), registerB = ref.registerA.acceptVisitor(self), immediateValue =  byte2)
        self.machineCode[self.instructionAddresses[ref]+12] = MachineWord(address = self.instructionAddresses[ref]+12, opcode = SLL_Opcode, operator = SLL_Operator, registerA = ref.registerA.acceptVisitor(self), registerB = ref.registerA.acceptVisitor(self), immediateValue = 8)
        self.machineCode[self.instructionAddresses[ref]+16] = MachineWord(address = self.instructionAddresses[ref]+16, opcode = ADDI_Opcode, operator = ADDI_Operator, registerA = ref.registerA.acceptVisitor(self), registerB = ref.registerA.acceptVisitor(self), immediateValue =  byte1)
        self.machineCode[self.instructionAddresses[ref]+20] = MachineWord(address = self.instructionAddresses[ref]+20, opcode = SLL_Opcode, operator = SLL_Operator, registerA = ref.registerA.acceptVisitor(self), registerB = ref.registerA.acceptVisitor(self), immediateValue = 8)
        self.machineCode[self.instructionAddresses[ref]+24] = MachineWord(address = self.instructionAddresses[ref]+24, opcode = ADDI_Opcode, operator = ADDI_Operator, registerA = ref.registerA.acceptVisitor(self), registerB = ref.registerA.acceptVisitor(self), immediateValue =  byte0)

    def visitRetPseudoInstruction(self,ref,parameters = []):
        (JR_Opcode,JR_Operator) = OPCODES["JR"]
        RBRegister = RegisterReference(29)
        self.machineCode[self.instructionAddresses[ref]] = MachineWord(address = self.instructionAddresses[ref], opcode = JR_Opcode, operator = JR_Operator, registerB = RBRegister.acceptVisitor(self))

    def visitCallPseudoInstruction(self,ref,parameters = []):
        (ADDI_Opcode, ADDI_Operator) = OPCODES["ADDI"]
        (SW_Opcode, SW_Operator) = OPCODES["SW"]
        (SUBI_Opcode, SUBI_Operator) = OPCODES["SUBI"]
        (J_Opcode, J_Operator) = OPCODES["J"]
        (LW_Opcode, LW_Operator) = OPCODES["LW"]
        RARegister = RegisterReference(29)
        FPRegister = RegisterReference(28)
        SPRegister = RegisterReference(27)
        address = ref.labelReference.acceptVisitor(self,parameters=["J",self.instructionAddresses[ref]+24])
        self.machineCode[self.instructionAddresses[ref]] = MachineWord(address = self.instructionAddresses[ref], opcode = SW_Opcode, operator = SW_Operator, registerA = FPRegister.acceptVisitor(self), registerB = SPRegister.acceptVisitor(self))
        self.machineCode[self.instructionAddresses[ref]+4] = MachineWord(address = self.instructionAddresses[ref], opcode = ADDI_Opcode, operator = ADDI_Operator, registerA = FPRegister.acceptVisitor(self), registerB = SPRegister.acceptVisitor(self), immediateValue = 0)
        self.machineCode[self.instructionAddresses[ref]+8] = MachineWord(address = self.instructionAddresses[ref], opcode = SUBI_Opcode, operator = SUBI_Operator, registerA = SPRegister.acceptVisitor(self), registerB = SPRegister.acceptVisitor(self), immediateValue = 4)
        self.machineCode[self.instructionAddresses[ref]+12] = MachineWord(address = self.instructionAddresses[ref], opcode = SW_Opcode, operator = SW_Operator, registerA = RARegister.acceptVisitor(self), registerB = SPRegister.acceptVisitor(self))
        self.machineCode[self.instructionAddresses[ref]+16] = MachineWord(address = self.instructionAddresses[ref], opcode = SUBI_Opcode, operator = SUBI_Operator, registerA = SPRegister.acceptVisitor(self), registerB = SPRegister.acceptVisitor(self), immediateValue = 4)
        self.machineCode[self.instructionAddresses[ref]+20] = MachineWord(address = self.instructionAddresses[ref], opcode = ADDI_Opcode, operator = ADDI_Operator, registerA = RARegister.acceptVisitor(self), registerB = RegisterReference(31).acceptVisitor(self), immediateValue = 4)
        self.machineCode[self.instructionAddresses[ref]+24] = MachineWord(address = self.instructionAddresses[ref], opcode = J_Opcode, operator = J_Operator, immediateAddress = address)
        self.machineCode[self.instructionAddresses[ref]+28] = MachineWord(address = self.instructionAddresses[ref], opcode = SUBI_Opcode, operator = SUBI_Operator, registerA = SPRegister.acceptVisitor(self), registerB = FPRegister.acceptVisitor(self), immediateValue = 4)
        self.machineCode[self.instructionAddresses[ref]+32] = MachineWord(address = self.instructionAddresses[ref], opcode = LW_Opcode, operator = LW_Operator, registerA = RARegister.acceptVisitor(self), registerB = SPRegister.acceptVisitor(self))
        self.machineCode[self.instructionAddresses[ref]+36] = MachineWord(address = self.instructionAddresses[ref], opcode = ADDI_Opcode, operator = ADDI_Operator, registerA = SPRegister.acceptVisitor(self), registerB = SPRegister.acceptVisitor(self), immediateValue = 4)
        self.machineCode[self.instructionAddresses[ref]+40] = MachineWord(address = self.instructionAddresses[ref], opcode = LW_Opcode, operator = LW_Operator, registerA = FPRegister.acceptVisitor(self), registerB = SPRegister.acceptVisitor(self))



##################
####Visitor#######
class AddressAssignmentVisitor(object):
    def __init__(self,addresses, currentAddress, labelBindings):
        self.addresses = addresses
        self.currentAddress = currentAddress
        self.labelBindings = labelBindings

    def align(self):
        if self.currentAddress % 4 != 0:
          self.currentAddress = self.currentAddress + 4 - (self.currentAddress % 4)  

    def visitRegisterReference(self, registerReference, parameters = []):
        #Visit Register Reference
        pass
    def visitImmediate(self, immediate, parameters = []):
        #Visit Immediate Code Here
        pass
    def visitLabelReference(self, labelReference, parameters = []):
        #Visit Label Reference
        pass
    def visitPortReference(self, portReference, parameters = []):
        #Visit Port References
        pass
    def visitAsciiz(self, asciiz, parameters = []):
        #Visit Asciiz
        self.addresses[asciiz] = self.currentAddress
        self.currentAddress = self.currentAddress + len(asciiz.string) + 1
        self.align()
    def visitByte(self, byte, parameters = []):
        #Visit Byte
        self.addresses[byte] = self.currentAddress
        self.currentAddress = self.currentAddress + len(byte.bytes)
        self.align()
    def visitDataSegment(self, dataSegment, parameters = []):
        #Visit Data Segment
        if dataSegment.address:
            self.currentAddress = dataSegment.address
            self.align()
    def visitTextSegment(self, textSegment, parameters = []):
        #Visit Text Segment
        if textSegment.address:
            self.currentAddress = textSegment.address
            self.align()
    def visitMachineInstruction(self, machineInstruction, parameters = []):
        self.addresses[machineInstruction] = self.currentAddress
        self.currentAddress = self.currentAddress + 4
    def visitThreeRegisterMachineInstruction(self, ref, parameters = []):
        #Visit Three Register Machine Instruction
        return self.visitMachineInstruction(ref, parameters)
    def visitTwoRegisterImmediateMachineInstruction(self, ref,parameters = []):
        #Visit Two Register Immediate Machine Instruction
        return self.visitMachineInstruction(ref, parameters)
    def visitFourRegisterMachineInstruction(self, ref, parameters = []):
        #Visit Four Register Machine Instruction
        return self.visitMachineInstruction(ref, parameters)
    def visitTwoRegisterMachineInstruction(self, ref, parameters = []):
        #Visit Two Register Machine Instruction
        return self.visitMachineInstruction(ref, parameters)
    def visitOneRegisterMachineInstruction(self, ref, parameters = []):
        #Visit One Register Machine Instruction
        return self.visitMachineInstruction(ref, parameters)
    def visitImmediateMachineInstruction(self, ref, parameters = []):
        #Visit Immediate Machine Instruciton
        return self.visitMachineInstruction(ref, parameters)
    def visitOneRegisterImmediateMachineInstruction(self, ref, parameters = []):
        #Visit One Register Immediate Machine Instruction
        return self.visitMachineInstruction(ref, parameters)
    def visitOneRegisterOnePortMachineInstruction(self, ref, parameters = []):
        #Visit One Register One Port Machine Instruction
        return self.visitMachineInstruction(ref, parameters)
    def visitLoadAddressPseudoInstruction(self, ref, parameters = []):
        #Visit Load Addresss Pseudo Instruction
        self.addresses[ref] = self.currentAddress
        self.currentAddress = self.currentAddress + 28
    def visitCallPseudoInstruction(self, ref, parameters = []):
        self.addresses[ref] = self.currentAddress
        self.currentAddress = self.currentAddress + 44
    def visitRetPseudoInstruction(self, ref, parameters = []):
        self.addresses[ref] = self.currentAddress
        self.currentAddress = self.currentAddress + 4


##################
        
class Directive(object):
    def __init__(self,lineNumber,operator):
        self.operator = operator
        self.lineNumber = lineNumber

class Asciiz(Directive):
    def __init__(self,lineNumber,string,labels = []):
        super(Asciiz,self).__init__(lineNumber,".ASCIIZ")
        self.string = string
        self.labels = labels
    def acceptVisitor(self, visitor, parameters = []):
        return visitor.visitAsciiz(self,parameters)

class Byte(Directive):
    def __init__(self,lineNumber,bytes,labels = []):
        super(Byte,self).__init__(lineNumber,".byte")
        self.bytes = bytes
        self.labels = labels
    def acceptVisitor(self, visitor, parameters = []):
        return visitor.visitByte(self,parameters)

class DataSegment(Directive):
    def __init__(self,lineNumber,address = None):
        super(DataSegment,self).__init__(lineNumber,".data")
        self.address = address
    def acceptVisitor(self, visitor, parameters = []):
        return visitor.visitDataSegment(self,parameters)

class TextSegment(Directive):
    def __init__(self,lineNumber,address = None):
        super(TextSegment,self).__init__(lineNumber,".text")
        self.address = address
    def acceptVisitor(self, visitor, parameters = []):
        return visitor.visitTextSegment(self,parameters)
#####################

class Instruction(object):
     def __init__(self,lineNumber,opcode,operands,labels = []):
         self.lineNumber = lineNumber
         self.opcode = opcode
         self.operands = operands
         self.labels = labels

class MachineInstruction(Instruction):
   def __init__(self,lineNumber,opcode,operands,labels = []):
       super(MachineInstruction,self).__init__(lineNumber,opcode,operands,labels)
       def acceptVisitor(self, visitor, parameters = []):
        return visitor.visitMachineInstruction(self,parameters)

class ThreeRegisterMachineInstruction(MachineInstruction):
    def __init__(self,lineNumber,opcode,operands,labels = []):
        super(ThreeRegisterMachineInstruction,self).__init__(lineNumber,opcode,operands,labels)
        self.registerA = operands[0]
        self.registerB = operands[1]
        self.registerC = operands[2]
    def acceptVisitor(self, visitor, parameters = []):
        return visitor.visitThreeRegisterMachineInstruction(self,parameters)

class TwoRegisterImmediateMachineInstruction(MachineInstruction):
    def __init__(self,lineNumber,opcode,operands,labels = []):
        super(TwoRegisterImmediateMachineInstruction,self).__init__(lineNumber,opcode,operands,labels)
        self.registerA = operands[0]
        self.registerB = operands[1]
        self.immediate = operands[2] if len(operands) == 3 else Immediate(0)
    def acceptVisitor(self, visitor, parameters = []):
        return visitor.visitTwoRegisterImmediateMachineInstruction(self,parameters)
class FourRegisterMachineInstruction(MachineInstruction):
    def __init__(self,lineNumber,opcode,operands,labels = []):
        super(FourRegisterMachineInstruction,self).__init__(lineNumber,opcode,operands,labels)
        self.registerA = operands[0]
        self.registerB = operands[1]
        self.registerC = operands[2]
        self.registerD = operands[3]
    def acceptVisitor(self, visitor, parameters = []):
        return visitor.visitFourRegisterMachineInstruction(self,parameters)
class TwoRegisterMachineInstruction(MachineInstruction):
    def __init__(self,lineNumber,opcode,operands,labels = []):
        super(TwoRegisterMachineInstruction,self).__init__(lineNumber,opcode,operands,labels)
        self.registerA = operands[0]
        self.registerB = operands[1]
    def acceptVisitor(self, visitor, parameters = []):
        return visitor.visitTwoRegisterMachineInstruction(self,parameters)
class OneRegisterMachineInstruction(MachineInstruction):
    def __init__(self,lineNumber,opcode,operands,labels = []):
        super(OneRegisterMachineInstruction,self).__init__(lineNumber,opcode,operands,labels)
        self.registerB = operands[0]
    def acceptVisitor(self, visitor, parameters = []):
        return visitor.visitOneRegisterMachineInstruction(self,parameters)
class ImmediateMachineInstruction(MachineInstruction):
    def __init__(self,lineNumber,opcode,operands,labels = []):
        super(ImmediateMachineInstruction,self).__init__(lineNumber,opcode,operands,labels)
        self.immediate = operands[0]
    def acceptVisitor(self, visitor, parameters = []):
        return visitor.visitImmediateMachineInstruction(self,parameters)
class OneRegisterImmediateMachineInstruction(MachineInstruction):
    def __init__(self,lineNumber,opcode,operands,labels = []):
        super(OneRegisterImmediateMachineInstruction,self).__init__(lineNumber,opcode,operands,labels)
        self.registerA = operands[0]
        self.immediate = operands[1]
    def acceptVisitor(self, visitor, parameters = []):
        return visitor.visitOneRegisterImmediateMachineInstruction(self,parameters)
class OneRegisterOnePortMachineInstruction(MachineInstruction):
    def __init__(self,lineNumber,opcode,operands,labels = []):
            super(OneRegisterOnePortMachineInstruction,self).__init__(lineNumber,opcode,operands,labels)
            self.registerA = operands[0]
            self.port = operands[1]
    def acceptVisitor(self, visitor, parameters = []):
        return visitor.visitOneRegisterOnePortMachineInstruction(self,parameters)

class LoadAddressPseudoInstruction(Instruction):
     def __init__(self,lineNumber,opcode,operands,labels = []):
            super(LoadAddressPseudoInstruction,self).__init__(lineNumber,opcode,operands,labels)
            self.registerA = operands[0]
            self.labelReference = operands[1]
     def acceptVisitor(self, visitor, parameters = []):
        return visitor.visitLoadAddressPseudoInstruction(self,parameters)

class CallPseudoInstruction(Instruction):
    def __init__(self,lineNumber,opcode,operands,labels = []):
        super(CallPseudoInstruction,self).__init__(lineNumber,opcode,operands,labels)
        self.labelReference = operands[0]
    def acceptVisitor(self,visitor,parameters = []):
        return visitor.visitCallPseudoInstruction(self,parameters)

class RetPseudoInstruction(Instruction):
    def __init__(self,lineNumber,opcode,operands,labels = []):
        super(RetPseudoInstruction,self).__init__(lineNumber,opcode,operands,labels)
    def acceptVisitor(self,visitor,parameters = []):
        return visitor.visitRetPseudoInstruction(self,parameters)

class AssemblerAst(object):
    def __init__(self):
        self.labelBindings = {}
        self.instructionAddresses = {}
        self.instructions = []


def readFile(filename):
    lines = []
    with open(filename, 'r') as f:
        for line in f:
            if line[0] != '#':
                if line != "" and line[-1] == "\n":
                    line = line[:-1]
                lines.append(line)
    return lines

def parse(inputStr):
    parsed = []
    for line in inputStr:
        m = re.match("[ \\t]*([A-Za-z_][A-Za-z_.0-9]*:)?[ \\t]*\\.asciiz[ \\t]*(\"([^\\\\]|\\\\[nt\"\\\\])*\")",line)
        if m:
            if m.group(1) == '':
                parsed.append(['.asciiz',m.group(2)])
            else:
                parsed.append([m.group(1),'.asciiz',m.group(2)])
        else:
            s = re.split('[ \\t]+|,',line)
            parsed.append(filter(lambda x:x != "",s))
    return parsed

def toAST(parsed):
    errorsFound = False
    labels = []
    assemblerAst = AssemblerAst()
    ast = assemblerAst.instructions
    for i in range(len(parsed)):
        lineNumber = i
        line = parsed[i]
        j = 0
        while j < len(line) and re.match("[A-Za-z_][A-Za-z_.0-9]*:",line[j]):
            labels.append(line[j][:-1])
            j = j+1
        if j == len(line): continue
        if line[j] == ".asciiz":
            string = line[j + 1][1:-1].decode("string_escape")
            ast.append(Asciiz(lineNumber,string,labels = labels))
            labels = []
        elif line[j] == ".byte":
            operands = [parseOperand(o) for o in line[j+1:]]
            for o in operands:
                if o is None:
                    errorsFound = True
                    printError(lineNumber,"Malformed Operand",line=line)
                    continue
                if not isinstance(o,Immediate) or o.immediate not in range(256):
                    errorsFound = True
                    printError(lineNumber,"Byte accepts only numbers between 0 and 255",line=line)
                    continue
            if errorsFound:
                continue
            ast.append(Byte(lineNumber,[o.immediate for o in operands],labels = labels))
            labels = []
        elif line[j] == ".data":
            operands = [parseOperand(o) for o in line[j+1:]]
            if len(operands) not in range(1):
                errorsFound = True
                printError(lineNumber,"Malformed .data directive",line=line)
                continue
            if len(operands) == 1 and not isinstance(operands[0],Immediate):
                errorsFound = True
                printError(lineNumber,".data operand must be a number",line=line)
                continue
            address = operands[0].immediate if len(operands) == 1 else None
            ast.append(DataSegment(lineNumber, address))
        elif line[j] == ".text":
            operands = [parseOperand(o) for o in line[j+1:]]
            if len(operands) not in range(2):
                errorsFound = True
                printError(lineNumber,"Malformed .text directive",line=line)
                continue
            if len(operands) == 1 and not isinstance(operands[0],Immediate):
                errorsFound = True
                printError(lineNumber,".text operand must be a number",line=line)
                continue
            address = operands[0].immediate if len(operands) == 1 else None
            ast.append(TextSegment(lineNumber,address))
        elif line[j] in FORMS:
            operands = [parseOperand(o) for o in line[j+1:]]
            for o in operands:
                if o is None:
                    errorsFound = True
                    printError(lineNumber,"Malformed Operand",line=line)
                    continue
            if errorsFound:
                continue
            if FORMS[line[j]] == 1:
                if len(operands) != 3:
                    errorsFound = True
                    printError(lineNumber,"Instruction takes only 3 operands",line=line)
                    continue
                for o in operands:
                    if not isinstance(o,RegisterReference):
                        errorsFound = True
                        printError(lineNumber,"Instruction only accepts registers",line=line)
                        continue
                if errorsFound:
                    continue
                ast.append(ThreeRegisterMachineInstruction(lineNumber,line[j],operands,labels))
                labels = []
            elif FORMS[line[j]] == 2:
                if len(operands) != 3:
                    errorsFound = True
                    printError(lineNumber,"Instruction takes only 3 operands",line=line)
                    continue
                if not isinstance(operands[0],RegisterReference) or not isinstance(operands[1],RegisterReference) or not isinstance(operands[2],Immediate):
                    errorsFound = True
                    printError(lineNumber,"Instruction must be in form Register, Register, Immediate",line=line)
                    continue
                if errorsFound:
                    continue
                ast.append(TwoRegisterImmediateMachineInstruction(lineNumber,line[j],operands,labels))
                labels = []
            elif FORMS[line[j]] == 3:
                if len(operands) != 4:
                    errorsFound = True
                    printError(lineNumber,"Instruction takes only 4 operands",line=line)
                    continue
                for o in operands:
                    if not isinstance(o,RegisterReference):
                        errorsFound = True
                        printError(lineNumber,"Instruction only accepts registers",line=line)
                        continue
                if errorsFound:
                    continue
                ast.append(FourRegisterMachineInstruction(lineNumber,line[j],operands,labels))
                labels = []
            elif FORMS[line[j]] == 4:
                if len(operands) != 2:
                    errorsFound = True
                    printError(lineNumber,"Instruction takes only 2 operands",line=line)
                    continue
                for o in operands:
                    if not isinstance(o,RegisterReference):
                        errorsFound = True
                        printError(lineNumber,"Instruction only accepts registers",line=line)
                        continue
                if errorsFound:
                    continue
                ast.append(TwoRegisterMachineInstruction(lineNumber,line[j],operands,labels))
                labels = []
            elif FORMS[line[j]] == 5:
                if len(operands) != 1:
                    errorsFound = True
                    printError(lineNumber,"Instruction takes only 1 operand",line=line)
                    continue
                for o in operands:
                    if not isinstance(o,RegisterReference):
                        errorsFound = True
                        printError(lineNumber,"Instruction only accepts registers",line=line)
                        continue
                if errorsFound:
                    continue
                ast.append(OneRegisterMachineInstruction(lineNumber,line[j],operands,labels))
                labels = []
            elif FORMS[line[j]] == 6:
                if len(operands) != 1:
                    errorsFound = True
                    printError(lineNumber,"Instruction takes only 1 operand",line=line)
                    continue
                for o in operands:
                    if not isinstance(o,LabelReference):
                        errorsFound = True
                        printError(lineNumber,"Instruction only accepts Label References",line=line)
                        continue
                if errorsFound:
                    continue
                ast.append(ImmediateMachineInstruction(lineNumber,line[j],operands,labels))
                labels = []
            elif FORMS[line[j]] == 7:
                if len(operands) != 2:
                    errorsFound = True
                    printError(lineNumber,"Instruction takes only 2 operands",line=line)
                    continue
                if not isinstance(operands[0],RegisterReference) or not isinstance(operands[1],LabelReference):
                    errorsFound = True
                    printError(lineNumber,"Instruction must be in form Register, Label Reference",line=line)
                    continue
                if errorsFound:
                    continue
                ast.append(OneRegisterImmediateMachineInstruction(lineNumber,line[j],operands,labels))
                labels = []
            elif FORMS[line[j]] == 8:
                if len(operands) != 3 and len(operands) != 2:
                    errorsFound = True
                    printError(lineNumber,"Instruction takes only 3 or 2 operands",line=line)
                    continue
                if not isinstance(operands[0],RegisterReference) or not isinstance(operands[1],RegisterReference) or (len(operands)==3 and not isinstance(operands[2],Immediate)):
                    errorsFound = True
                    printError(lineNumber,"Instruction must be in form Register, Register, Immediate",line=line)
                    continue
                if errorsFound:
                    continue
                ast.append(TwoRegisterImmediateMachineInstruction(lineNumber,line[j],operands,labels))
                labels = []
            elif FORMS[line[j]] == 9:
                if len(operands) != 2:
                    errorsFound = True
                    printError(lineNumber,"Instruction takes only 2 operands",line=line)
                    continue
                if not isinstance(operands[0],RegisterReference) or not isinstance(operands[1],PortReference):
                    errorsFound = True
                    printError(lineNumber,"Instruction must be in form Register, Port",line=line)
                    continue
                ast.append(OneRegisterOnePortMachineInstruction(lineNumber,line[j],operands,labels))
                labels = []
            elif FORMS[line[j]] == 10:
                if len(operands) != 2:
                    errorsFound = True
                    printError(lineNumber,"Instruction takes only 2 operands",line=line)
                    continue
                if not isinstance(operands[0],RegisterReference) or not isinstance(operands[1],LabelReference):
                    errorsFound = True
                    printError(lineNumber,"Instruction must be in form Register, Label",line=line)
                    continue
                ast.append(LoadAddressPseudoInstruction(lineNumber,line[j],operands,labels))
                labels = []
            elif FORMS[line[j]] == 11:
                if len(operands) != 1:
                    errorsFound = True
                    printError(lineNumber,"Instruction takes only 1 operand",line=line)
                    continue
                for o in operands:
                    if not isinstance(o,LabelReference):
                        errorsFound = True
                        printError(lineNumber,"Instruction only accepts Label References",line=line)
                        continue
                if errorsFound:
                    continue
                ast.append(CallPseudoInstruction(lineNumber,line[j],operands,labels))
                labels = []
            elif FORMS[line[j]] == 12:
                if len(operands) != 0:
                    errorsFound = True
                    printError(lineNumber,"Instruction takes no operands")
                    continue
                if errorsFound:
                    continue
                ast.append(RetPseudoInstruction(lineNumber,line[j],operands,labels))
                labels = []
        else:
            errorsFound = True
            printError(lineNumber,"Invalid Opcode '%s'" % line[j],line=line)
            continue

    if errorsFound:
        return None
    return assemblerAst


def analyze(ast):
    errorsFound = False
    for i in range(len(ast.instructions)):
        if hasattr(ast.instructions[i],"labels"):
            for l in ast.instructions[i].labels:
                ast.labelBindings[l] = ast.instructions[i]
    for i in ast.instructions:
        if hasattr(i,"operands"):
            for o in i.operands:
                if isinstance(o, LabelReference) and o.label not in ast.labelBindings:
                    errorsFound = True
                    printError(i.lineNumber,"Undefined Label %s" % o.label)
    visitor = AddressAssignmentVisitor(ast.instructionAddresses, 0, ast.labelBindings)
    for i in ast.instructions:
        i.acceptVisitor(visitor)
    return errorsFound

def toMachineCode(ast):
    machineCode = MachineObjectBuilder(ast.labelBindings,ast.instructionAddresses)
    for i in ast.instructions:
        i.acceptVisitor(machineCode)
    return machineCode.machineCode
        
def finalOutput(machineCode, outputVisitor):
    highestAddress = max(machineCode.keys())
    i = 0
    while i <= highestAddress:
        if i in machineCode:
            machineCode[i].acceptVisitor(outputVisitor)
        else:
            outputVisitor.outputBlank()
        i = i + 4

def main(argv):
    inputStr = []
    for a in argv[1:]:
        inputStr = inputStr+readFile(a)
    parsed = parse(inputStr)
    ast = toAST(parsed)
    if ast:
        analyzed = analyze(ast)
        #print >> sys.stderr,ast.labelBindings
        #print >> sys.stderr,ast.instructionAddresses
        if not analyzed:
            machineCode = toMachineCode(ast)
            outputStr = finalOutput(machineCode, TextOutputVisitor(sys.stdout))
    #print (machineCode)

if __name__ == "__main__":
    main(sys.argv)

