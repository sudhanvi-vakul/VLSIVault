class alu_scoreboard extends uvm_component;
  `uvm_component_utils(alu_scoreboard)
  
  uvm_analysis_imp #(alu_seq_item, alu_scoreboard) imp;
  
  int unsigned total_checks;
  int unsigned pass_count;
  int unsigned fail_count;
  
  function new(string name = "alu_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    imp = new("imp", this);
  endfunction
  
  function void write (alu_seq_item tr);
    tr.exp_result = alu_ref(tr.a, tr.b, tr.op);
    
    total_checks++;
    if(tr.act_result == tr.exp_result) begin
      pass_count++;
      `uvm_info("SCOREBOARD", $sformatf("Observed transaction: %s exp_result=%0d", tr.convert2string(), tr.exp_result), UVM_MEDIUM)
    end
    else begin
      fail_count++;
      `uvm_error("SCOREBOARD", $sformatf("Mismatch: a=%0d b=%0d op=%0d exp=%0d act=%0d", tr.a, tr.b, tr.op, tr.exp_result, tr.act_result))
    end
  endfunction
  
  function void report_phase(uvm_phase phase);
    `uvm_info("SCOREBOARD REPORT", $sformatf("Scoreboard report: Total=%0d Pass=%0d Fail=%0d", total_checks, pass_count, fail_count), UVM_LOW)
  endfunction
  
endclass