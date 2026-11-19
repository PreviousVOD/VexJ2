package j2.bus.ahb5

import spinal.core._
import spinal.lib._

/** IHI0033C profile. Exclusive_Transfers and interface parity are not implemented. HMASTER is
  * provided for the additional uses permitted by section 10.3.
  */
case class Ahb5Config(
    addressWidth: Int = 32,
    dataWidth: Int = 32,
    masterWidth: Int = 4,
    secureTransfers: Boolean = false,
    extendedMemoryTypes: Boolean = false,
    writeStrobes: Boolean = false
) {
  require(addressWidth >= 10 && addressWidth <= 64)
  require(Set(8, 16, 32, 64, 128, 256, 512, 1024)(dataWidth))
  require(masterWidth > 0)
  def bytes: Int     = dataWidth / 8
  def protWidth: Int = if (extendedMemoryTypes) 7 else 4
}

object Ahb5Trans {
  def IDLE   = B"00"
  def BUSY   = B"01"
  def NONSEQ = B"10"
  def SEQ    = B"11"
}

object Ahb5Burst {
  def SINGLE = B"000"
  def INCR   = B"001"
  def WRAP4  = B"010"
  def INCR4  = B"011"
  def WRAP8  = B"100"
  def INCR8  = B"101"
  def WRAP16 = B"110"
  def INCR16 = B"111"
}

/** Address-phase payload; distinct from write data, which belongs to the following phase. */
case class Ahb5Control(config: Ahb5Config) extends Bundle {
  val HADDR     = UInt(config.addressWidth bits)
  val HWRITE    = Bool()
  val HSIZE     = UInt(3 bits)
  val HBURST    = Bits(3 bits)
  val HPROT     = Bits(config.protWidth bits)
  val HTRANS    = Bits(2 bits)
  val HMASTLOCK = Bool()
  val HMASTER   = UInt(config.masterWidth bits)
  val HNONSEC   = if (config.secureTransfers) Bool() else null

  def isTransfer: Bool = HTRANS(1)

  /** Address for BUSY following this beat, including wrapping bursts (section 3.6). */
  def nextAddress: UInt = {
    val increment  = (U(1, config.addressWidth bits) |<< HSIZE).resize(config.addressWidth)
    val sequential = HADDR + increment
    val mask       = UInt(config.addressWidth bits)
    mask := 0
    switch(HBURST) {
      is(Ahb5Burst.WRAP4)(mask := (increment |<< 2) - 1)
      is(Ahb5Burst.WRAP8)(mask := (increment |<< 3) - 1)
      is(Ahb5Burst.WRAP16)(mask := (increment |<< 4) - 1)
    }
    Mux(
      HBURST =/= Ahb5Burst.SINGLE && !HBURST(0),
      (HADDR & ~mask) | (sequential & mask),
      sequential
    )
  }
}

/** Manager interface. HCLK/HRESETn are supplied by Spinal's clock domain. */
case class Ahb5Master(config: Ahb5Config) extends Bundle with IMasterSlave {
  val address = Ahb5Control(config)
  val HWDATA  = Bits(config.dataWidth bits)
  val HWSTRB  = if (config.writeStrobes) Bits(config.bytes bits) else null
  val HRDATA  = Bits(config.dataWidth bits)
  val HREADY  = Bool()
  val HRESP   = Bool()
  override def asMaster(): Unit = {
    out(address, HWDATA)
    if (config.writeStrobes) out(HWSTRB)
    in(HRDATA, HREADY, HRESP)
  }
}

/** Subordinate interface: HREADY qualifies address acceptance; HREADYOUT completes data. */
case class Ahb5(config: Ahb5Config) extends Bundle with IMasterSlave {
  val address        = Ahb5Control(config)
  val HSEL           = Bool()
  val HREADY         = Bool()
  val HWDATA         = Bits(config.dataWidth bits)
  val HWSTRB         = if (config.writeStrobes) Bits(config.bytes bits) else null
  val HRDATA         = Bits(config.dataWidth bits)
  val HREADYOUT      = Bool()
  val HRESP          = Bool()
  def accepted: Bool = HSEL && HREADY && address.isTransfer
  override def asMaster(): Unit = {
    out(address, HSEL, HREADY, HWDATA)
    if (config.writeStrobes) out(HWSTRB)
    in(HRDATA, HREADYOUT, HRESP)
  }
}

/** Internal elastic transport. This is not an AMBA wire interface. */
private[ahb5] case class Ahb5Request(config: Ahb5Config) extends Bundle {
  val control = Ahb5Control(config)
  val data    = Bits(config.dataWidth bits)
  val strobes = if (config.writeStrobes) Bits(config.bytes bits) else null
}

private[ahb5] case class Ahb5Response(config: Ahb5Config) extends Bundle {
  val data  = Bits(config.dataWidth bits)
  val error = Bool()
}

private[ahb5] case class Ahb5Transport(config: Ahb5Config) extends Bundle with IMasterSlave {
  val request  = Stream(Ahb5Request(config))
  val response = Stream(Ahb5Response(config))
  // Sampled only at an upstream HREADY boundary, including IDLE/BUSY cycles.
  val reservation        = Bool()
  val reservationControl = Ahb5Control(config)
  val continuing         = Bool()
  override def asMaster(): Unit = {
    master(request)
    slave(response)
    out(reservation, reservationControl, continuing)
  }
}
