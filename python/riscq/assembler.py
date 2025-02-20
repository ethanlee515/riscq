class TypeR:
    def __init__(self, opcode: str, rd: int, funct3: str, rs1: int, rs2: int, funct7: str):
        self.opcode = opcode
        self.rd = rd
        self.funct3 = funct3
        self.rs1 = rs1
        self.rs2 = rs2
        self.funct7 = funct7
    
    def bin_str(self, length: int = 32):
        res = self.funct7 + f'{self.rs2:0{5}b}' + f'{self.rs1:0{5}b}' + self.funct3 + f'{self.rd:0{5}b}' + self.opcode
        if length > 32:
            res = '0' * (length - 32) + res
        return res

class TypeI:
    def __init__(self, opcode: str, rd: int, funct3: str, rs1: int, imm: int):
        self.opcode = opcode
        self.rd = rd
        self.funct3 = funct3
        self.rs1 = rs1
        self.imm = imm
    
    def bin_str(self, length: int = 32):
        res = f'{self.imm:0{12}b}' + f'{self.rs1:0{5}b}' + self.funct3 + f'{self.rd:0{5}b}' + self.opcode
        if length > 32:
            res = '0' * (length - 32) + res
        return res    

class TypeB:
    def __init__(self, opcode: str, funct3: str, rs1: int, rs2: int, imm: int):
        self.opcode = opcode
        self.funct3 = funct3
        self.rs1 = rs1
        self.rs2 = rs2
        self.imm = imm
    
    def bin_str(self, length: int = 32):
        imm = f'{self.imm:0{13}b}'[::-1]
        res = imm[12] + (imm[5:11])[::-1] + f'{self.rs2:0{5}b}' + f'{self.rs1:0{5}b}' + self.funct3 + (imm[1:5])[::-1] + imm[11] + self.opcode
        if length > 32:
            res = '0' * (length - 32) + res
        return res    

class TypeS:
    def __init__(self, opcode: str, funct3: str, rs1: int, rs2: int, imm: int):
        self.opcode = opcode
        self.funct3 = funct3
        self.rs1 = rs1
        self.rs2 = rs2
        self.imm = imm
    
    def bin_str(self, length: int = 32):
        imm = f'{self.imm:0{12}b}'[::-1]
        res = (imm[5:12])[::-1] + f'{self.rs2:0{5}b}' + f'{self.rs1:0{5}b}' + self.funct3 + (imm[0:5])[::-1] + self.opcode
        if length > 32:
            res = '0' * (length - 32) + res
        return res    

class ADD(TypeR):
    def __init__(self, rd: int, rs1: int, rs2: int):
        super().__init__(opcode = '0110011', rd = rd, funct3 = '000', rs1 = rs1, rs2 = rs2, funct7 = '0000000')

class SUB(TypeR):
    def __init__(self, rd: int, rs1: int, rs2: int):
        super().__init__(opcode = '0110011', rd = rd, funct3 = '000', rs1 = rs1, rs2 = rs2, funct7 = '0100000')
    
class ADDI(TypeI):
    def __init__(self, rd: int, rs1: int, imm: int):
        super().__init__(opcode = '0010011', rd = rd, funct3 = '000', rs1 = rs1, imm = imm)

class BEQ(TypeB):
    def __init__(self, rs1: int, rs2: int, imm: int):
        super().__init__(opcode = '1100011', funct3 = '000', rs1 = rs1, rs2 = rs2, imm = imm)

class SETTIME:
    def __init__(self, time: int):
        self.time = time
    
    def bin_str(self, length: int):
        res = f'{self.time:0{32}b}' + '0'*64 + '00000000000000000011000101111111'
        return res

class WAIT:
    def __init__(self, time: int):
        self.time = time
    
    def bin_str(self, length: int):
        res = f'{self.time:0{32}b}' + '0'*64 + '00000000000000000011000111111111'
        return res
        
class CARRIER:
    def __init__(self, freq: int, phase: int, id: int = 0, freqWidth = 16, phaseWidth = 16):
        self.id = id
        self.freq = freq
        self.phase = phase
        self.freqWidth = freqWidth
        self.phaseWidth = phaseWidth
    
    def bin_str(self, length: int):
        res = f'{self.id:0{5}b}' + f'{self.freq:0{self.freqWidth}b}' + f'{self.phase:0{self.phaseWidth}b}' 
        opcode = '011000011111111'
        zero_len = 128 - len(res) - len(opcode)
        res += '0'*zero_len + opcode
        return res

class PULSE:
    def __init__(self, start: int, addr: int, duration: int, phase: int, amp: int, id: int = 0, freq: int = 0):
        self.start = start
        self.addr = addr
        self.duration = duration
        self.phase = phase
        self.freq = freq
        self.amp = amp
        self.id = id

    def bin_str(self, length: int):
        res = ''
        res += f'{self.id:0{5}b}'
        res += f'{self.phase:0{16}b}'
        res += f'{self.freq:0{16}b}'
        res += f'{self.duration:0{12}b}'
        res += f'{self.start:0{32}b}'
        res += f'{self.addr:0{12}b}'
        res += f'{self.amp:0{16}b}'
        opcode = '011000001111111'
        zero_len = 128 - len(res) - len(opcode)
        res += '0'*zero_len + opcode
        return res

class READOUT(TypeI):
    def __init__(self, id: int, time: int):
        super().__init__(opcode = '1111011', rd = 0, funct3 = '000', rs1 = id, imm = time)

class WRITER(TypeI):
    def __init__(self, rd: int, id: int):
        super().__init__(opcode = '1111011', rd = rd, funct3 = '001', rs1 = id, imm = 0)

class WRITEI(TypeI):
    def __init__(self, rd: int, id: int):
        super().__init__(opcode = '1111011', rd = rd, funct3 = '010', rs1 = id, imm = 0)

class LW(TypeI):
    def __init__(self, imm: int, rs1: int, rd: int):
        super().__init__(opcode = '0000011', rd = rd, funct3 = '010', rs1 = rs1, imm = imm)

class SW(TypeS):
    def __init__(self, imm: int, rs1: int, rs2: int):
        super().__init__(opcode = '0100011', funct3 = '010', imm = imm, rs1 = rs1, rs2 = rs2)

def assemble(insts):
    res = [inst.bin_str(128) for inst in insts]
    return res

if __name__ == '__main__':
    add = ADD(7, 7, 7)
    beq = BEQ(1, 2, 3)

    print(assemble([add, beq]))