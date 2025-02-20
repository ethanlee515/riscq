package riscq.tester

import riscq.execute.PulseOpParam

object ByteHelper {
  def fromBinStr(binaryString: String): Array[Byte] = {
    // Ensure the binary string length is a multiple of 8
    require(binaryString.length % 8 == 0, "Binary string length must be a multiple of 8")

    // Convert binary string to byte array
    (0 until binaryString.length / 8).map { i =>
      // Get each byte (8 bits)
      val byteString = binaryString.slice(i * 8, (i + 1) * 8)
      // Convert to byte
      Integer.parseInt(byteString, 2).toByte
    }.toArray
  }

  def intToBinStr(x: BigInt, b: Int): String = {
    val compx = if (x < 0) (x + (1 << (b - 1))) else x
    compx.toString(2).reverse.padTo(b, '0').reverse
  }
}

object RvInst {
  def typeR(opcode: String, funct7: String, funct3: String, rs1: Int, rs2: Int, rd: Int) = {
    assert(opcode.length == 7)
    assert(funct7.length == 7)
    assert(funct3.length == 3)
    var res = funct7
    res += ByteHelper.intToBinStr(rs2, 5)
    res += ByteHelper.intToBinStr(rs1, 5)
    res += funct3
    res += ByteHelper.intToBinStr(rd, 5)
    res += opcode
    assert(res.length == 32)
    res = "0" * (128 - 32) + res
    res
  }

  def addInst(rs1: Int, rs2: Int, rd: Int) = typeR("0110011", "0000000", "000", rs1, rs2, rd)
  def subInst(rs1: Int, rs2: Int, rd: Int) = typeR("0110011", "0100000", "000", rs1, rs2, rd)

  def typeI(opcode: String, funct3: String, imm: Int, rs1: Int, rd: Int) = {
    assert(opcode.length == 7)
    assert(funct3.length == 3)
    var res = ByteHelper.intToBinStr(imm, 12)
    res += ByteHelper.intToBinStr(rs1, 5)
    res += funct3
    res += ByteHelper.intToBinStr(rd, 5)
    res += opcode
    assert(res.length == 32)
    res = "0" * (128 - 32) + res
    res
  }

  def addiInst(imm: Int, rs1: Int, rd: Int) = typeI("0010011", "000", imm, rs1, rd)
  def lwInst(offset: Int, rs1: Int, rd: Int): String = typeI("0000011", "010", imm = offset, rs1 = rs1, rd = rd)

  def typeB(opcode: String, funct3: String, imm: Int, rs1: Int, rs2: Int) = {
    assert(opcode.length == 7)
    assert(funct3.length == 3)
    val immStr = ByteHelper.intToBinStr(imm, 12).reverse
    var res = immStr.slice(11, 12)
    res += immStr.slice(4,10).reverse
    res += ByteHelper.intToBinStr(rs2, 5)
    res += ByteHelper.intToBinStr(rs1, 5)
    res += funct3
    res += immStr.slice(0, 4).reverse
    res += immStr.slice(10, 11)
    res += opcode
    assert(res.length == 32, s"length is ${res.length}")
    res = "0" * (128 - 32) + res
    res
  }

  def beqInst(imm: Int, rs1: Int, rs2: Int) = typeB("1100011", "000", imm, rs1, rs2)

  def typeS(opcode: String, funct3: String, imm: Int, rs1: Int, rs2: Int) = {
    assert(opcode.length == 7)
    assert(funct3.length == 3)
    val immStr = ByteHelper.intToBinStr(imm, 12).reverse
    println(s"immstr: ${immStr}")
    var res = immStr.slice(5, 12).reverse
    res += ByteHelper.intToBinStr(rs2, 5)
    res += ByteHelper.intToBinStr(rs1, 5)
    res += funct3
    res += immStr.slice(0, 5).reverse
    res += opcode
    assert(res.length == 32, s"length is ${res.length}")
    res = "0" * (128 - 32) + res
    res
  }
  def swInst(offset: Int, rs1: Int, rs2: Int): String = typeS("0100011", "010", imm = offset, rs1 = rs1, rs2 = rs2)
}

object Qubic {
  def timerInst(resetTime: Int) = {
    var res = ""
    res += ByteHelper.intToBinStr(resetTime, 32)
    res += "0" * 64
    val opcode = "00000000000000000011000101111111"
    res += opcode
    res
  }
  def waitInst(waitUntil: Int) = {
    var res = ""
    res += ByteHelper.intToBinStr(waitUntil, 32)
    res += "0" * 64
    val opcode = "00000000000000000011000111111111"
    res += opcode
    res
  }
  def carrierInst(freq: Int, phase: Int, id: Int = 0, freqWidth: Int = 16, phaseWidth: Int = 16): String = {
    var res = ""
    res += ByteHelper.intToBinStr(id, 5)
    res += ByteHelper.intToBinStr(freq, freqWidth)
    res += ByteHelper.intToBinStr(phase, phaseWidth)
    val opcode = "011000011111111"
    val zeroLength = 128 - res.length() - opcode.length()
    res += "0" * zeroLength + opcode
    res
  }
  def pulseInst(puop: PulseOpParam, start: Int, addr: Int, duration: Int, phase: Int, freq: Int, amp: Int, id: Int = 0): String = {
    var res = ""
    res += ByteHelper.intToBinStr(id, puop.idWidth)
    res += ByteHelper.intToBinStr(phase, puop.phaseWidth)
    res += ByteHelper.intToBinStr(freq, puop.freqWidth)
    res += ByteHelper.intToBinStr(duration, puop.durationWidth)
    res += ByteHelper.intToBinStr(start, puop.startWidth)
    res += ByteHelper.intToBinStr(addr, puop.addrWidth)
    res += ByteHelper.intToBinStr(amp, puop.ampWidth)
    // val idStr = ByteHelper.intToBinStr(id, puop.idWidth)
    val opcode = "011000001111111"
    // val zeroLength = 128 - res.length() - idStr.length() - opcode.length()
    val zeroLength = 128 - res.length() - opcode.length()
    // res += "0" * zeroLength + idStr + opcode
    res += "0" * zeroLength + opcode
    res
  }
  def readInst(id: Int, time: Int, start: Int = 0): String = {
    val startStr = ByteHelper.intToBinStr(start, 32)
    val timeStr = ByteHelper.intToBinStr(time, 12)
    var idStr = ByteHelper.intToBinStr(id, 5)
    val opcode = "1111011"
    val funct3 = "000"
    val zeroLength = 128 - startStr.length - timeStr.length - idStr.length - funct3.length - 5 - opcode.length 
    val res = startStr + "0"*zeroLength + timeStr + idStr + funct3 + "00000" + opcode
    res
  }
  def writeRInst(id: Int, rd: Int): String = {
    var idStr = ByteHelper.intToBinStr(id, 5)
    val rdStr = ByteHelper.intToBinStr(rd, 5)
    val opcode = "1111011"
    val funct3 = "001"
    val zeroLength = 128 - idStr.length - funct3.length - rdStr.length - opcode.length
    val res = "0"*zeroLength + idStr + funct3 + rdStr + opcode
    res
  }
  def writeIInst(id: Int, rd: Int): String = {
    var idStr = ByteHelper.intToBinStr(id, 5)
    val rdStr = ByteHelper.intToBinStr(rd, 5)
    val opcode = "1111011"
    val funct3 = "010"
    val zeroLength = 128 - idStr.length - funct3.length - rdStr.length - opcode.length
    val res = "0"*zeroLength + idStr + funct3 + rdStr + opcode
    res
  }
}