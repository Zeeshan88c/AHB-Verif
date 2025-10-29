class ahb_sequence extends uvm_sequence #(ahb_seq_item);
  // =============================== //
  //    UVM FACTORY REGISTRATION     //
  // =============================== //
  `uvm_object_utils(ahb_sequence)
  
  // =============================== //
  // Constructor                     //
  // =============================== //
  function new(string name = "ahb_sequence");
    super.new(name);
  endfunction
  
  // =============================== //
  // Task Body                       //
  // =============================== //
  virtual task body();
    `uvm_info(get_type_name(), "Starting APB Sequence", UVM_LOW);
    
    req = ahb_seq_item::type_id::create("req");
    
    forever begin
      start_item(req);
      assert(req.randomize() with {
        HADDR inside {[32'h0 : 32'h0000_00FF]};
        HWDATA inside {[32'h0 : 32'hFFFF_FFFF]};
        HSIZE == 3'b10;
        HTRANS == 2'b10;
        HBURST == '0;
        HWRITE inside {0,1};
        HSEL == 1'b1;
      }) else begin
        `uvm_error(get_type_name(), "Randomization Failed");
      end
      finish_item(req);
    end
  endtask
  
endclass
    \