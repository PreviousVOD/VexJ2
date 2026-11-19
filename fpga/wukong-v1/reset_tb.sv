`timescale 1ns/1ps
module wukong_reset_tb #(parameter real SOC_PERIOD_NS = 1000.0 / 72.0);
  reg clk = 0;
  always #(SOC_PERIOD_NS / 2.0) clk = ~clk;
  reg button = 0;
  reg locked = 0;
  wire [0:0] reset;
  wukong_reset dut (
    .slowest_sync_clk(clk), .ext_reset_in(button), .aux_reset_in(1'b0),
    .mb_debug_sys_rst(1'b0), .dcm_locked(locked), .peripheral_reset(reset)
  );
  realtime last_edge;
  always @(posedge clk) last_edge = $realtime;
  always @(negedge reset[0]) begin
    // UNISIM FDRE includes clock/input/output propagation delays (100 ps each).
    if ($realtime > 100 && (!clk || $realtime - last_edge > 1.0))
      $fatal(1, "Reset release was not on a rising SoC clock edge");
  end
  task await_release;
    integer count;
    begin
      count = 0;
      while (reset[0] !== 1'b0 && count < 512) begin
        @(posedge clk); #1; count = count + 1;
      end
      if (reset[0] !== 1'b0) $fatal(1, "Reset did not release");
    end
  endtask
  initial begin
    // Cold configuration with no button pulse and no PLL lock.
    repeat (64) @(posedge clk);
    #1;
    if (reset[0] !== 1'b1) $fatal(1, "Reset released before clock lock");
    locked = 1;
    await_release();
    #7; locked = 0;
    repeat (32) @(posedge clk);
    #1;
    if (reset[0] !== 1'b1) $fatal(1, "Lock loss did not assert reset");
    locked = 1;
    await_release();
    #7; button = 1;
    repeat (32) @(posedge clk);
    #1;
    if (reset[0] !== 1'b1) $fatal(1, "Button did not assert reset");
    button = 0;
    await_release();
    $display("WUKONG_RESET_PASS: cold startup, lock loss, button, synchronous release");
    $finish;
  end
  initial begin
    #100000;
    $fatal(1, "Reset test timeout");
  end
endmodule
