read_liberty lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog build/top_synth.v
link_design top

# Change this line for experiments
read_sdc constraints/top_tight.sdc

puts "\n===== SETUP (MAX) CHECKS =====\n"
report_checks -path_delay max -digits 3

puts "\n===== HOLD (MIN) CHECKS =====\n"
report_checks -path_delay min -digits 3

puts "\n===== SUMMARY =====\n"
report_worst_slack -max
report_worst_slack -min
report_tns

