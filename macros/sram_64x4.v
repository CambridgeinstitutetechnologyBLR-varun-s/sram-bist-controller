//==============================================================
// Black-box declaration for OpenRAM SRAM
// Used only during synthesis / OpenLane
//==============================================================

`timescale 1ns/1ps
`default_nettype none

module sram_64x4(
`ifdef USE_POWER_PINS
    inout vdd,
    inout gnd,
`endif

    input           clk0,
    input           csb0,
    input           web0,
    input  [5:0]    addr0,
    input  [3:0]    din0,
    output [3:0]    dout0
);

endmodule

`default_nettype wire
