class alu_base_test extends uvm_test;
  `uvm_component_utils(alu_base_test)
  alu_env env;
  int unsigned ntxn = 10;
  
  function new(string name = "alu_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = alu_env::type_id::create("env", this);
    
    if($value$plusargs("ntxn=%0d", ntxn)) begin
      `uvm_info("BASE_TEST", $sformatf("ntxn set via plusarg: %0d", ntxn), UVM_LOW)
    end
  endfunction
      
  task run_phase(uvm_phase phase);
    alu_random_seq seq;
    super.run_phase(phase);
    phase.raise_objection(this);
    seq = alu_random_seq::type_id::create("seq");
    seq.ntxn = ntxn;
    seq.start(env.agent.seqr);
        
    phase.drop_objection(this);
    endtask
      
endclass