package riscq.misc

import spinal.core._
import spinal.lib._

case class IBUFGDS() extends BlackBox {
  val I = in Bool()
  val IB = in Bool()
  val O = out Bool()
}

case class IbufgdsTestTop() extends Component {
  val eclk = IBUFGDS()
  val eclkI = in Bool()
  val eclkIb = in Bool()
  eclk.I := eclkI
  eclk.IB := eclkIb
  
  val cd = ClockDomain.current
  cd.clock := eclk.O

  val oreg = out port Reg(Bool())
  oreg := ~oreg
}

case class NoClkModule() extends Component {
  val i = in Bool()
  val o = out Bool()
  o := ~i
}

case class ClockInterface() extends Component {
  val clk500m_clk_p = in Bool()
  val clk500m_clk_n = in Bool()
  clk500m_clk_p.addAttribute("X_INTERFACE_INFO", "xilinx.com:interface:diff_clock:1.0 clk500m_diff CLK_P ")
  clk500m_clk_n.addAttribute("X_INTERFACE_INFO", "xilinx.com:interface:diff_clock:1.0 clk500m_diff CLK_N ")

  val clk100m_clk_p = in Bool()
  val clk100m_clk_n = in Bool()
  clk100m_clk_p.addAttribute("X_INTERFACE_INFO", "xilinx.com:interface:diff_clock:1.0 clk100m_diff CLK_P ")
  clk100m_clk_n.addAttribute("X_INTERFACE_INFO", "xilinx.com:interface:diff_clock:1.0 clk100m_diff CLK_N ")

  val user_sysref_clk_p = in Bool()
  val user_sysref_clk_n = in Bool()
  user_sysref_clk_p.addAttribute("X_INTERFACE_INFO", "xilinx.com:interface:diff_clock:1.0 user_sysref_diff CLK_P ")
  user_sysref_clk_n.addAttribute("X_INTERFACE_INFO", "xilinx.com:interface:diff_clock:1.0 user_sysref_diff CLK_N ")

  val clk500m = out Bool()
  clk500m.addAttribute("X_INTERFACE_INFO", "xilinx.com:signal:clock:1.0 clk500m CLK")
  val clk100m = out Bool()
  clk100m.addAttribute("X_INTERFACE_INFO", "xilinx.com:signal:clock:1.0 clk100m CLK")
  val user_sysref = out Bool()
  user_sysref.addAttribute("X_INTERFACE_INFO", "xilinx.com:signal:clock:1.0 user_sysref CLK")

  val ibufgds500m = IBUFGDS()
  val ibufgds100m = IBUFGDS()
  val ibufgdsUserSysref = IBUFGDS()

  ibufgds500m.I := clk500m_clk_p
  ibufgds500m.IB := clk500m_clk_n
  clk500m := ibufgds500m.O
  ibufgds100m.I := clk100m_clk_p
  ibufgds100m.IB := clk100m_clk_n
  clk100m := ibufgds100m.O
  ibufgdsUserSysref.I := user_sysref_clk_p
  ibufgdsUserSysref.IB := user_sysref_clk_n
  user_sysref := ibufgdsUserSysref.O
}

object ClkIfcTest extends App {
  SpinalVerilog(ClockInterface())
}

object IbufgdsTest extends App {
  SpinalVerilog(IbufgdsTestTop())
}