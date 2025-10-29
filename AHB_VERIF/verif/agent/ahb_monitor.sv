class ahb_monitor extends uvm_monitor;
  //==============================//
  //   UVM FACTORY REGISTRATION   //
  //==============================//
  `uvm_component_utils(ahb_monitor)
  
  virtual ahb_intf vif;
  uvm_analysis_port #(ahb_seq_item) out_port;
  ahb_seq_item send_packet;
  semaphore lock = new(1);
  
  // temporary signals 
  bit [31:0] temp_HADDR;
  bit [31:0] temp_HWDATA;
  bit [2:0]  temp_HSIZE;
  bit [2:0]  temp_HBURST;
  bit [1:0]  temp_HTRANS;
  bit        temp_HWRITE;
  bit        temp_HSEL;
  
  
  //===============================
  // Constructor
  //===============================
  function new(string name = "ahb_monitor",uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  //===============================
  // Build Phase
  //===============================
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    send_packet = ahb_seq_item::type_id::create("send_packet");
    out_port = new("out_port", this);
    if(!(uvm_config_db #(virtual ahb_intf)::get(this,"*", "vif", vif)))begin
      `uvm_fatal(get_type_name(), "Can't get interface");
    end
  endfunction
  
  //===============================
  // Main Phase
  //===============================
  virtual task main_phase(uvm_phase phase);
    super.main_phase(phase);
    
    `uvm_info(get_type_name(),"Main Phase Starting .....", UVM_NONE);
    collect_data();
    `uvm_info(get_type_name(),"Main Phase Ending .....", UVM_NONE);
  endtask
  
  //===============================
  // Collect data
  //===============================
  task collect_data();
    forever begin
      
      lock.get();
      
      // ======================= //
      //      ADDRESS PHASE      //
      // ======================= //
      @(posedge vif.HCLK iff(vif.HRESET && vif.HREADY))
      temp_HADDR = vif.HADDR;
      temp_HWRITE = vif.HWRITE;
      temp_HTRANS = vif.HTRANS;
      temp_HSIZE = vif.HSIZE;
      temp_HWDATA = vif.HWDATA;
      temp_HBURST = vif.HBURST;
      temp_HSEL = vif.HSEL;
      
      lock.put();
      
      // ====================== //
      //       DATA PHASE       //
      // ====================== //
      @(posedge vif.HCLK iff (vif.HRESET &&  vif.HREADY))
      send_packet.HREADY = vif.HREADY;
      send_packet.HRESP  = vif.HRESP;
      send_packet.HRDATA = vif.HRDATA;
      send_packet.HADDR  = temp_HADDR;
      send_packet.HWRITE = temp_HWRITE;
      send_packet.HWDATA = temp_HWDATA;
      send_packet.HTRANS = temp_HTRANS;
      send_packet.HSIZE = temp_HSIZE;
      send_packet.HBURST = temp_HBURST;
      send_packet.HSEL   = temp_HSEL;
      
      send_packet.display_bridg("AHB MONITOR");
      
      out_port.write(send_packet);
      
    end
    
  endtask
  
endclass
      
      
  