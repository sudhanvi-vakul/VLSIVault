class alu_rand_test extends uvm_test;
  `uvm_component_utils(alu_rand_test);
  
  alu_env env;
  
  function new(string name = "alu_rand_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = alu_env::type_id::create("env", this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    
    alu_random_seq seq;
    int ntxn;
    
    phase.raise_objection(this);

    seq = alu_random_seq::type_id::create("seq");
    
    if($value$plusargs("ntxn=%0d", ntxn)) begin
      seq.ntxn = ntxn;
      `uvm_info("RAND_TEST", $sformatf("ntxn set via plusarg: %0d", ntxn), UVM_LOW)
    end
    
    seq.start(env.agent.seqr);
    #500;
    phase.drop_objection(this);
    
  endtask
endclass