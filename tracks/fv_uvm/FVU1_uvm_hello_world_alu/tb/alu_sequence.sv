class alu_sequence extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_sequence)
  
  function new(string name = "alu_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    alu_seq_item req;
    
    repeat (10) begin
    req = alu_seq_item::type_id::create("req");
    if(!req.randomize())
      `uvm_error("SEQ","Randomization Failed")
    start_item(req);
    finish_item(req);
    end
  endtask
endclass