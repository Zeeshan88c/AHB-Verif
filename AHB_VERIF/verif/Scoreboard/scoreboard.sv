`uvm_analysis_imp_decl(_rpkt)

class scoreboard extends uvm_scoreboard;
  // ================================ //
  //    UVM FACTORY REGISTRATION      //
  // ================================ //
  `uvm_component_utils(scoreboard)
  
  //=================================
  // Analysis imp port
  //=================================
  uvm_analysis_imp_rpkt #(ahb_seq_item, scoreboard) received;
  
  //=================================
  // Memory and Counters
  //=================================
  logic [31:0] mem [0:255];
  int match;
  int mismatch;
  uvm_event in_scb_evnt;
  string report;

  //=================================
  // Constructor
  //=================================
  function new(string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  //=================================
  // Build Phase
  //=================================
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    received = new("received", this);
    in_scb_evnt = uvm_event_pool::get_global("ingr_scb_evnt");
    
    for(int i = 0; i < 256; i++)begin
      mem[i] = '0;
    end
    
  endfunction
  
  //=================================
  // Write Method
  //=================================
  virtual function void write_rpkt(ahb_seq_item item);
    if (item == null) begin
      `uvm_error(get_type_name(), "Received NULL transaction")
      return;
    end
    
    if (item.HREADY) begin
      if (item.HWRITE) begin
        // Write to memory
        mem[item.HADDR[7:0]] = item.HWDATA;
        `uvm_info(get_type_name(),
                  $sformatf("WRITE: Addr=0x%0h Data=0x%0h", item.HADDR, item.HWDATA),
                  UVM_LOW)
      end
      else begin
        // Read and compare data
        if (item.HRDATA == mem[item.HADDR[7:0]]) begin
          match++;
          `uvm_info(get_type_name(),
                    $sformatf("READ MATCH: Addr=0x%0h Exp=0x%0h Got=0x%0h",
                              item.HADDR, mem[item.HADDR[7:0]], item.HRDATA),
                    UVM_LOW)
        end
        else begin
          mismatch++;
          `uvm_error(get_type_name(),
                     $sformatf("READ MISMATCH: Addr=0x%0h Exp=0x%0h Got=0x%0h",
                               item.HADDR, mem[item.HADDR[7:0]], item.HRDATA))
        end
      end
    end
  endfunction
  
  //=================================
  // Main Phase
  //=================================
   virtual task main_phase(uvm_phase phase);
    super.main_phase(phase);
    
     wait(((match + mismatch) == 50))
    
    in_scb_evnt.trigger();

    report = {"=========================================\n",
              " SCOREBOARD FINAL REPORT\n",
              "-----------------------------------------\n",
              $sformatf(" Total Matches   : %0d\n", match),
              $sformatf(" Total Mismatches: %0d\n", mismatch),
              "=========================================\n"};

    `uvm_info(get_type_name(), report, UVM_NONE)

    if (mismatch == 0)
      `uvm_info(get_type_name(), "TEST PASSED All read data matched expected values.", UVM_NONE)
    else
      `uvm_error(get_type_name(), $sformatf("TEST FAILED %0d mismatches found.", mismatch))
      
  endtask


endclass
