class alu_seq_item extends uvm_sequence_item;
  rand bit [7:0] a;
  rand bit [7:0] b;
  rand bit [2:0] op;
  
  bit [7:0] act_result;
  bit [7:0] exp_result;
  
  `uvm_object_utils_begin(alu_seq_item)
  `uvm_field_int(a, UVM_ALL_ON)
  `uvm_field_int(b, UVM_ALL_ON)
  `uvm_field_int(op, UVM_ALL_ON)
  `uvm_field_int(act_result, UVM_ALL_ON)
  `uvm_field_int(exp_result, UVM_ALL_ON)
  `uvm_object_utils_end
  
  constraint op_range {
    op inside {[3'b000:3'b110]}; }
  
  constraint op_weight {
    op dist {
      3'b000 := 30,
      3'b001 := 20,
      3'b010 := 15,
      3'b011 := 10,
      3'b100 := 10,
      3'b101 := 10,
      3'b110 := 5 };
  }
      
  function new(string name = "alu_seq_item");
    super.new(name);
  endfunction
  
  function string convert2string();
    return $sformatf("a=%0d b=%0d op=%0d", a, b, op);
  endfunction
  
endclass