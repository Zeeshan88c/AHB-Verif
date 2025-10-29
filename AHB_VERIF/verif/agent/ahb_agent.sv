class ahb_agent extends uvm_agent;
  //====================================//
  //       UVM FACTORY REGISTRATION     //
  //====================================//
  `uvm_component_utils(ahb_agent)
  
  ahb_driver drv;
  ahb_monitor mon;
  uvm_sequencer #(ahb_seq_item) seqr;
  
  //===================================
  // Constructor
  //===================================
  function new(string name = "ahb_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  //=====================================
  // Build Phase
  //=====================================
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    drv = ahb_driver::type_id::create("drv", this);
    mon = ahb_monitor :: type_id::create("mon", this);
    seqr = uvm_sequencer #(ahb_seq_item)::type_id::create("seqr", this);
  endfunction
  
  //=====================================
  // Connect Phase
  //=====================================
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
  
endclass