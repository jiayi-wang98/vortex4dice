create_clock [get_ports clk_i]  -period 2500 -waveform {0 500} -name clk

set_clock_uncertainty 50  [get_clocks clk]
set_clock_transition -fall 50 [get_clocks clk]
set_clock_transition -rise 50 [get_clocks clk]
#
set_input_delay 0 -clock clk [remove_from_collection [all_inputs] clk]
set_output_delay 0 -clock clk  [all_outputs]
#set_max_delay 4000 -from [all_inputs] -to [all_outputs]

#set_max_area 0