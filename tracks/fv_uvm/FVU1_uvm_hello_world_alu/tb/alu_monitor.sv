class alu_monitor extends uvm_monitor;
  `uvm_component_utils(alu_monitor)
  
  virtual alu_if mon_if;
  uvm_analysis_port #(alu_seq_item) ap;
  
  function new(string name = "alu_monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual alu_if)::get(this, "", "vif", mon_if))
      `uvm_fatal("NO VIF", "Virtual interface is not set for monitor")
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    alu_seq_item tr;
    logic [7:0] last_result;
    bit tracking_output =  0;
    forever begin
      @(posedge mon_if.clk);
      
      if(!mon_if.rst_n) begin
        tr = null;
        tracking_output = 0;
        continue;
      end
      
      if(mon_if.in_valid && mon_if.in_ready) begin
        tr = alu_seq_item::type_id::create("tr");
        tr.a = mon_if.a;
        tr.b = mon_if.b;
        tr.op = mon_if.op;
      end
      
      if(mon_if.out_valid && !mon_if.out_ready) begin
        if(!tracking_output) begin
          tracking_output = 1;
          last_result = mon_if.result;
        end
        else begin
          if(mon_if.result != last_result) begin
            `uvm_error("MON_VIO", $sformatf("Result changed while out_valid = 1 and out_ready = 0. old=%0d new=%0d", last_result, mon_if.result))
          end
        end
      end
      else begin
        tracking_output = 0;
      end
      
      if(mon_if.out_valid && mon_if.out_ready) begin
        if (tr!=null) begin
        tr.act_result = mon_if.result;
          `uvm_info("MON", $sformatf("Observed transaction: %s act_result=%0d", tr.convert2string(), tr.act_result), UVM_MEDIUM)
        ap.write(tr);
        tr = null;
        end
      end
    end
  endtask
endclass

