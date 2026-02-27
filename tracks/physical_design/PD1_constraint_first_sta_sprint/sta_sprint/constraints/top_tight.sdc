# Tight constraints (experiment)

# Faster clock + larger uncertainty
create_clock -name clk -period 2.000 [get_ports clk]
set_clock_uncertainty 0.400 [get_clocks clk]

set_input_delay  2.000 -clock clk [get_ports {a[*] b[*] op[*]}]
set_output_delay 2.000 -clock clk [get_ports {result[*]}] 

set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 [get_ports {a[*] b[*] op[*]}]
set_load 0.05 [get_ports {result[*]}]
