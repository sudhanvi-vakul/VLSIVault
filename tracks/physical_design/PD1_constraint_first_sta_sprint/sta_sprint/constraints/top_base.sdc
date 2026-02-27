# Baseline constraints

# Clock: 10 ns period (100 MHz)
create_clock -name clk -period 10.000 [get_ports clk]

# Uncertainty models jitter/skew/margin
set_clock_uncertainty 0.200 [get_clocks clk]

# IO delays model timing budgets of surrounding logic
set_input_delay  2.000 -clock clk [get_ports {a[*] b[*] op[*]}]
set_output_delay 2.000 -clock clk [get_ports {result[*]}]
