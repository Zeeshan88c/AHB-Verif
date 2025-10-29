//===============================================
// INTERFACE 
//===============================================
interface ahb_intf (
    input logic HCLK,
    input logic HRESET
);

    logic [31:0] HWDATA;
    logic [31:0] HADDR;
    logic [2:0]  HSIZE;
    logic [2:0]  HBURST;
    logic        HSEL;
    logic        HWRITE;
    logic [1:0]  HTRANS;

    logic        HRESP;
    logic        HREADY;
    logic [31:0] HRDATA;

endinterface : ahb_intf

