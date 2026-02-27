class alu_random_seq extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_random_seq)
  
  int unsigned ntxn;
  
  function new(string name = "alu_random_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    alu_seq_item req;
    
    repeat (ntxn) begin
      req = alu_seq_item::type_id::create("req");
      start_item(req);
      assert(req.randomize())
        else `uvm_error("ALU_RAND_SEQ", "Ramdomization failed")
      finish_item(req);
    end
  endtask
endclass
