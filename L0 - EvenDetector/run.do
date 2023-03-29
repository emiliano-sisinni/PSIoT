#Riviera Pro
vsim even_detector_testbench +access+r -dbg
vcd file dump.vcd
vcd add -r sim:/*
run 2 us