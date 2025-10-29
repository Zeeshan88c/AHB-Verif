`timescale 1ns/1ns

// AHB protocol definitions
`define NON_SEQ     2'b10
`define SEQ         2'b11
`define BUSY        2'b01
`define IDLE        2'b00
`define OKAY        1'b0
`define ERROR       1'b1

module ahb_slave(
  input              clk,
  input              hresetn,
  input              hsel,
  input              hwrite,
  input       [1:0]  htrans,
  input       [2:0]  hsize,
  input       [2:0]  hburst,
  input       [31:0] haddr,
  input       [31:0] hwdata,
  output reg         hready,
  output reg         hresp,
  output reg [31:0]  hrdata
);

  // -------------------------------------------------
  // Internal memory - 256 x 32-bit (same as scoreboard)
  // -------------------------------------------------
  reg [31:0] mem [0:255];

  // -------------------------------------------------
  // Internal registers
  // -------------------------------------------------
  reg [31:0] addr_reg;
  reg        write_reg;
  reg [31:0] wdata_reg;
  reg [1:0]  state;

  // -------------------------------------------------
  // State encoding
  // -------------------------------------------------
  localparam IDLE_S   = 2'd0;
  localparam ACCESS_S = 2'd1;

  integer i;

  // -------------------------------------------------
  // Main AHB Slave Logic
  // -------------------------------------------------
  always @(posedge clk or negedge hresetn) begin
    if (!hresetn) begin
      hrdata     <= 32'b0;
      hready     <= 1'b1;
      hresp      <= `OKAY;
      addr_reg   <= 32'b0;
      write_reg  <= 1'b0;
      wdata_reg  <= 32'b0;
      state      <= IDLE_S;

      for (i = 0; i < 256; i = i + 1)
        mem[i] <= 32'h0;
    end
    else begin
      case (state)

        // =======================================================
        // IDLE: Wait for a valid transfer (NON_SEQ or SEQ)
        // =======================================================
        IDLE_S: begin
          hready <= 1'b1;
          hresp  <= `OKAY;

          if (hsel && (htrans == `NON_SEQ || htrans == `SEQ)) begin
            addr_reg  <= haddr;     // Capture address
            write_reg <= hwrite;    // Capture direction
            wdata_reg <= hwdata;    // Capture data for write
            hready    <= 1'b0;      // Slave busy for one cycle
            hrdata    <= 32'b0;
            state     <= ACCESS_S;
          end
        end

        // =======================================================
        // ACCESS: Perform read or write to memory
        // =======================================================
        ACCESS_S: begin
          hready <= 1'b1;
          hresp  <= `OKAY;

          if (write_reg) begin
            // Write operation: same mapping as scoreboard
            mem[addr_reg[7:0]] <= wdata_reg;
          end 
          else begin
            // Read operation: same mapping as scoreboard
            hrdata <= mem[addr_reg[9:2]];
          end

          // Return to IDLE for next transaction
          state <= IDLE_S;
        end

        default: state <= IDLE_S;
      endcase
    end
  end

endmodule
