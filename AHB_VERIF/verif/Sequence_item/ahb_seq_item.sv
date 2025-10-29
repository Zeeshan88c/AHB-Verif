class ahb_seq_item extends uvm_sequence_item; 
  // ================================ //
  // Constructor                      //
  // ================================ //
  function new(string name = "ahb_seq_item");
    super.new(name);
  endfunction
  // ================================ //
  //    Transaction Fields            //
  // ================================ //
  rand bit [31:0] HADDR;
  rand bit [31:0] HWDATA;
  rand bit [1:0] HTRANS;
  rand bit [2:0] HSIZE;
  rand bit [2:0] HBURST;
  rand bit HSEL;
  rand bit HWRITE;
  
  bit [31:0] HRDATA;
  bit HRESP;
  bit HREADY;
  
  // ================================ //
  //        AUTOMATION MACROS         //
  // ================================ // 
  `uvm_object_utils_begin(ahb_seq_item)
    `uvm_field_int(HADDR,  UVM_ALL_ON + UVM_DEC)
    `uvm_field_int(HWRITE, UVM_ALL_ON + UVM_DEC)
    `uvm_field_int(HTRANS, UVM_ALL_ON + UVM_DEC)
    `uvm_field_int(HSIZE,  UVM_ALL_ON + UVM_DEC)
    `uvm_field_int(HBURST, UVM_ALL_ON + UVM_DEC)
    `uvm_field_int(HWDATA, UVM_ALL_ON + UVM_DEC)

    `uvm_field_int(HRDATA, UVM_ALL_ON + UVM_DEC)
    `uvm_field_int(HREADY, UVM_ALL_ON + UVM_DEC)
    `uvm_field_int(HRESP,  UVM_ALL_ON + UVM_DEC)
  `uvm_object_utils_end
  
  // ================================ //
  // Custom Display Function          //
  // ================================ //
  virtual function void display_bridg(string name);
    string msg;
    
    msg = $sformatf("\nThis is being displayed from %s\n", name);
    msg = {msg, $sformatf(
      "HADDR = 0x%08h HWRITE = %0d HTRANS = 0x%0h\nHSIZE = 0x%0h HBURST = 0x%0h \nHWDATA = 0x%08h HRDATA = 0x%08h\nHREADY = %0d HRESP = %0d\n",
      HADDR, HWRITE, HTRANS, HSIZE, HBURST, HWDATA, HRDATA, HREADY, HRESP
    )};

    `uvm_info(name, msg, UVM_MEDIUM)
  endfunction // display_brdg


endclass