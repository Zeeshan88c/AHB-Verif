`timescale 1ns/1ns

module tb_ahb;

import uvm_pkg::*;
 `include "uvm_macros.svh"
 import ahb_pkg::*;

  //====================================
  // Clock and Reset
  //====================================
  bit HCLK;
  bit HRESET;

  //====================================
  // Interface Instance
  //====================================
  ahb_intf AHB_VIF (HCLK, HRESET);

  //====================================
  // DUT Instantiation
  //====================================
  ahb_slave dut (
      .clk     (AHB_VIF.HCLK),
      .hresetn (AHB_VIF.HRESET),
      .haddr   (AHB_VIF.HADDR),
      .hsel    (AHB_VIF.HSEL),
      .hwrite  (AHB_VIF.HWRITE),
      .hsize   (AHB_VIF.HSIZE),
      .hburst  (AHB_VIF.HBURST),
      .htrans  (AHB_VIF.HTRANS),
      .hwdata  (AHB_VIF.HWDATA),
      .hresp   (AHB_VIF.HRESP),
      .hready  (AHB_VIF.HREADY),
      .hrdata  (AHB_VIF.HRDATA)
  );

  //====================================
  // Clock Generation
  //====================================
  initial begin
    HCLK = 0;
    forever #5 HCLK = ~HCLK;
  end

  //====================================
  // Reset Generation
  //====================================
  initial begin
    HRESET = 0;
    #20 HRESET = 1;
  end

  //====================================
  // Waveform Dump
  //====================================
  initial begin
    $dumpfile("ahb_wave.vcd");
    $dumpvars(0, tb_ahb);
  end

  //====================================
  // UVM Configuration and Test Start
  //====================================
  initial begin
    uvm_config_db#(virtual ahb_intf)::set(null, "*", "vif", AHB_VIF);
    uvm_config_int::set(null, "*", "recording_detail", 1);
    run_test("base_test");  // Runs the test specified via +UVM_TESTNAME
  end

endmodule
