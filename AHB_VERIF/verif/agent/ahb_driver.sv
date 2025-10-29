class ahb_driver extends uvm_driver #(ahb_seq_item);
  //==============================//
  //   UVM FACTORY REGISTRATION   //
  //==============================//
  `uvm_component_utils(ahb_driver);
  
  virtual ahb_intf vif;
  semaphore lock = new(1);
  
  // ============================= //
  // Constructor                   //
  // ============================= //
  function new(string name = "ahb_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // ============================= //
  // BUILD PHASE                   //
  // ============================= //
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    req = ahb_seq_item::type_id::create("req");
    
    if(!(uvm_config_db #(virtual ahb_intf)::get(this, "*", "vif", vif)))begin
      `uvm_fatal(get_type_name(), "Can't get the interface");
    end
  endfunction
  
  // ============================= //
  // RUN PHASE                     //
  // ============================= //
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    `uvm_info(get_type_name(), "Run Phase Starting ......",UVM_LOW);
    
    forever begin
      fork
        drive_item(req);
        drive_item(req);
      join
    end
    
    `uvm_info(get_type_name(), "Run Phase Ending ......",UVM_LOW);
    
  endtask
  
  // ============================= //
  // DRIVE ITEM                    //
  // ============================= //
  virtual task drive_item(ahb_seq_item req);
    
    lock.get();
    
    seq_item_port.get(req);
    
    // ============================= //
    //      ADDRESS PHASE            //
    // ============================= //
    @(posedge vif.HCLK iff(vif.HRESET && vif.HREADY))
    vif.HADDR <= req.HADDR;
    vif.HSIZE <= req.HSIZE;
    vif.HTRANS <= req.HTRANS;
    vif.HWRITE <= req.HWRITE;
    vif.HBURST <= req.HBURST;
    vif.HSEL   <= req.HSEL;
    
    while(vif.HREADY != 1'b1)begin
      @(posedge vif.HCLK);
    end
    
    lock.put();
    
    // ============================ //
    // DATA PHASE                   //
    // ============================ //
    if(vif.HWRITE) begin
      vif.HWDATA <= req.HWDATA;
      while(vif.HREADY != 1'b1)begin
        @(posedge vif.HCLK);
      end
    end else begin
      while(vif.HREADY != 1'b1)begin
        @(posedge vif.HCLK);
      end
      req.HRDATA <= vif.HRDATA;
    end
    
    req.HRESP <= vif.HRESP;
    
    `uvm_info(get_type_name(), "Driving input signals to DUT", UVM_LOW);
  endtask
  
endclass
    
    
  