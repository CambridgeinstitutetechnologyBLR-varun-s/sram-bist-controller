############################################################
# constraints.sdc
# SRAM BIST Top-Level Timing Constraints
# Sky130 HD process, TT corner, 25°C, 1.80V, 100 MHz
#
# This file contains ONLY timing constraints.
# Analysis commands are kept in a separate STA script.
############################################################

# ----------------------------------------------------------
# 1. Primary clock (100 MHz, 50% duty cycle)
# ----------------------------------------------------------
create_clock -name clk -period 10.0 -waveform {0 5} [get_ports clk]

# ----------------------------------------------------------
# 2. Clock latency
#    - Source latency: external clock source delay (0.20 ns)
#    - Network latency: clock tree delay (0.00 ns until CTS is built)
# ----------------------------------------------------------
set_clock_latency -source 0.20 [get_clocks clk]
set_clock_latency 0.00 [get_clocks clk]

# ----------------------------------------------------------
# 3. Clock uncertainty and transition
# ----------------------------------------------------------
set_clock_uncertainty -setup 0.20 [get_clocks clk]
set_clock_uncertainty -hold  0.05 [get_clocks clk]
set_clock_transition 0.10 [get_clocks clk]

# ----------------------------------------------------------
# 4. Input constraints (start, rst_n)
# ----------------------------------------------------------
set_input_transition 0.10 [get_ports {start rst_n}]

# Option: driving cell (uncomment when liberty is available)
# Note: Replace 'sky130_fd_sc_hd__buf_2' with actual cell name.
# set_driving_cell -lib_cell sky130_fd_sc_hd__buf_2 [get_ports {start rst_n}]

set_input_delay -clock clk -max 1.00 [get_ports {start}]
set_input_delay -clock clk -min 0.00 [get_ports {start}]

# Reset is asynchronous; do not time it as synchronous
set_false_path -from [get_ports rst_n]

# ----------------------------------------------------------
# 5. Output constraints (done, pass_fail)
# ----------------------------------------------------------
set_output_delay -clock clk -max 1.00 [get_ports {done pass_fail}]
set_output_delay -clock clk -min 0.00 [get_ports {done pass_fail}]
set_load 0.05 [get_ports {done pass_fail}]

# ----------------------------------------------------------
# 6. Design rule constraints (optional, tool‑specific)
#    Commented out to avoid potential errors in some flows.
# ----------------------------------------------------------
# set_max_fanout 8 [current_design]
# set_max_capacitance 0.10 [current_design]
# set_max_transition 0.20 [current_design]

# ----------------------------------------------------------
# 7. No generated clocks or multicycle paths exist.
# ----------------------------------------------------------

############################################################
# End of constraints.sdc
############################################################
