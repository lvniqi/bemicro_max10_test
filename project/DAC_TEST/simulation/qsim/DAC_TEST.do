onerror {exit -code 1}
vlib work
vlog -work work DAC_TEST.vo
vlog -work work Waveform.vwf.vt
vsim -novopt -c -t 1ps -L fiftyfivenm_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate_ver -L altera_lnsim_ver work.BeMicro_MAX10_top_vlg_vec_tst -voptargs="+acc"
vcd file -direction DAC_TEST.msim.vcd
vcd add -internal BeMicro_MAX10_top_vlg_vec_tst/*
vcd add -internal BeMicro_MAX10_top_vlg_vec_tst/i1/*
run -all
quit -f
