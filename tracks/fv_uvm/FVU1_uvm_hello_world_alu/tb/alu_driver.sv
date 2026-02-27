class alu_driver extends uvm_driver #(alu_seq_item);
  `uvm_component_utils(alu_driver)
  
  virtual alu_if drv_if;
  
  function new(string name = "alu_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual alu_if)::get(this, "", "vif", drv_if))
      `uvm_fatal("NO VIF", "Virtual interface not set for driver")
  endfunction
      
  virtual task run_phase(uvm_phase phase);
    alu_seq_item req;
    drv_if.in_valid  <= 0;
    drv_if.a  <= 0;
    drv_if.b  <= 0;
    drv_if.op  <= 0;
    drv_if.out_ready <= 1;
    
    @(posedge drv_if.rst_n);
    repeat (2) @(posedge drv_if.clk);
    
    forever begin
      seq_item_port.get_next_item(req);
      `uvm_info("DRV", $sformatf("Driving Transaction: %s", req.convert2string()), UVM_MEDIUM)
      @(posedge drv_if.clk);
      while (!drv_if.in_ready) begin
        @(posedge drv_if.clk);
        `uvm_info("DRV_CYCLE", $sformatf("Cycle: in_valid=%0b in_ready=%0b a=%0d b=%0d op=%0d", drv_if.in_valid, drv_if.in_ready, drv_if.a, drv_if.b, drv_if.op), UVM_HIGH)
      end
      drv_if.a        <= req.a;
      drv_if.b        <= req.b;
      drv_if.op       <= req.op;
      drv_if.in_valid <= 1;
      
      @(posedge drv_if.clk);
      drv_if.in_valid <= 0;

    seq_item_port.item_done();
      
    end
  endtask
    
endclass