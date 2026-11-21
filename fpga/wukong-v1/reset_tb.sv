`timescale 1ns/1ps
module wukong_reset_tb #(parameter real SOC_PERIOD_NS = 1000.0 / 72.0);
  reg clk = 0;
  always #(SOC_PERIOD_NS / 2.0) clk = ~clk;
  reg button = 0;
  reg locked = 0;
  reg ddr_not_ready = 1;
  wire [0:0] reset;
  wukong_reset dut (
    .slowest_sync_clk(clk), .ext_reset_in(button), .aux_reset_in(ddr_not_ready),
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
    // Clock lock alone must not start the SoC before DDR calibration.
    repeat (256) @(posedge clk);
    #1;
    if (reset[0] !== 1'b1) $fatal(1, "Reset released before DDR calibration");
    ddr_not_ready = 0;
    await_release();
    // Even the minimum two-cycle synchronized readiness-loss pulse must reset.
    @(negedge clk); ddr_not_ready = 1;
    repeat (2) @(negedge clk);
    ddr_not_ready = 0;
    repeat (16) @(posedge clk);
    #1;
    if (reset[0] !== 1'b1) $fatal(1, "Brief DDR readiness loss did not assert reset");
    await_release();
    // A prolonged loss must hold reset beyond the normal release sequence.
    @(negedge clk); ddr_not_ready = 1;
    repeat (256) @(posedge clk);
    #1;
    if (reset[0] !== 1'b1) $fatal(1, "DDR readiness loss did not hold reset");
    ddr_not_ready = 0;
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
    // The same button restarts MIG, which must calibrate again after release.
    ddr_not_ready = 1;
    button = 0;
    repeat (256) @(posedge clk);
    #1;
    if (reset[0] !== 1'b1) $fatal(1, "Button release bypassed DDR calibration");
    ddr_not_ready = 0;
    await_release();
    $display("WUKONG_RESET_PASS: cold startup, calibration, brief readiness loss, lock loss, button, synchronous release");
    $finish;
  end
  initial begin
    #100000;
    $fatal(1, "Reset test timeout");
  end
endmodule
