class ahb_env extends uvm_env;
  // ============================== //
  //   UVM FACTORY REGISTERATION    //
  // ============================== //
  `uvm_component_utils(ahb_env)
  
  ahb_agent agnt;
  scoreboard scb;
  uvm_event in_scb_evnt;
  int WATCH_DOG;
  
  // ============================== //
  // Constructor                    //
  // ============================== //
  function new(string name = "ahb_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // ============================== //
  // Build Phase                    //
  // ============================== //
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    agnt = ahb_agent::type_id::create("agnt", this);
    scb = scoreboard::type_id::create("scb", this);
    
    in_scb_evnt = uvm_event_pool::get_global("ingr_scb_evnt");
  endfunction
  
  // ============================== //
  // Connect PHase                  //
  // ============================== //
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    agnt.mon.out_port.connect(scb.received);
    
  endfunction 
  
  // ============================== //
  // Main Phase                     //
  // ============================== //
  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "Main Phase Starting .....", UVM_NONE);
    super.main_phase(phase);
    
    WATCH_DOG = 0.5ms;
    
    fork 
      begin
        `uvm_info(get_type_name(), "Starting WATCH DOG Timer ....", UVM_LOW);
        #WATCH_DOG;
        `uvm_info(get_type_name(), "WATCH DOG Expired", UVM_MEDIUM);
        `uvm_fatal(get_type_name(), "Error event didn't triggered");
      end
      
      begin
        `uvm_info(get_type_name(), "wait for uvm_event",UVM_MEDIUM);
        in_scb_evnt.wait_trigger();
        `uvm_info(get_type_name(), "Scoreboard event triggered successfully", UVM_MEDIUM);
      end
    join_any
    
    phase.drop_objection(this);
    
  endtask
  
endclass
        