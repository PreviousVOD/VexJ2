package j2.soc

/** Ordered source ABI. Appending preserves vectors; reordering requires a firmware ABI change. */
object J2SocInterrupts {
  val names = Seq("CMT0", "CMT1", "SCI_ERI", "SCI_RXI", "SCI_TXI", "SCI_TEI")
}
