class alu_directed_seq extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_directed_seq)
  
  function new(string name = "alu_directed_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    alu_seq_item req;
    
    req = alu_seq_item::type_id::create("add_item");
    req.a = 10;
    req.b = 5;
    req.op = 3'b000;
    start_item(req);
    finish_item(req);
    
    req = alu_seq_item::type_id::create("sub_item");
    req.a = 20;
    req.b = 7;
    req.op = 3'b001;
    start_item(req);
    finish_item(req);
    
    req = alu_seq_item::type_id::create("and_item");
    req.a = 8'hAA;
    req.b = 8'h0F;
    req.op = 3'b010;
    start_item(req);
    finish_item(req);
    
    req = alu_seq_item::type_id::create("shl_item");
    req.a = 8'h03;
    req.b = 3;
    req.op = 3'b101;
    start_item(req);
    finish_item(req);
    
    req = alu_seq_item::type_id::create("xor_item");
    req.a = 3;
    req.b = 5;
    req.op = 3'b100;
    start_item(req);
    finish_item(req);
    
  endtask
endclass