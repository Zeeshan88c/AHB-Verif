class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  // =============================
  // Constructor Method
  // =============================
  function new(string name = "base_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  // =============================
  // Environment handles
  // =============================
   ahb_env my_env;
   ahb_sequence seq;
  // =============================
  // Virtual Interfaces
  // =============================
   virtual ahb_intf vif_in;

  // =============================
  // Build Phase Method
  // =============================
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // creating environment
    my_env = ahb_env::type_id::create("my_env",this);
    seq = ahb_sequence::type_id::create("seq");
    
    // getting virtual interfaces for vif_init_zero tasks
    if(!uvm_config_db#(virtual ahb_intf)::get(this,"","vif", vif_in))
    `uvm_fatal("inp_interface","Interface not accessed in cuboid_base_test")
   
  endfunction


  // =============================
  // Reset Phase Method
  // =============================
   virtual task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    super.reset_phase(phase);

    `uvm_info(get_type_name(), $sformatf("Staring reset_phase.."), UVM_MEDIUM)

    vif_init_zero(); 
    
    `uvm_info(get_type_name(), $sformatf("reset_phase done.."), UVM_MEDIUM)
    phase.drop_objection(this);
  endtask // reset_phase

  // ==============================================
  // all interfaces needs to intialize with zeros
  // ==============================================
  task vif_init_zero();
    
    // Assuming vif_in is your virtual interface handle
    vif_in.HADDR   = '0;
    vif_in.HSEL   = '0;
    vif_in.HWDATA = '0;
    vif_in.HSIZE = '0;
    vif_in.HBURST = '0;
    vif_in.HTRANS = '0;
    
  endtask
    
  //=============================
  // Run phase
  // =============================
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
      seq.start(my_env.agnt.seqr);
  endtask
    
endclass