vlib ${workdir}
vmap work ${workdir}
vmap work $MTI_HOME/uvm-1.1d/

vcom -work ${workdir} $srcdir/file_name.vhd +cover=bcesxf
vlog -64 -work ${workdir} -sv -f $BINDIR/compile.f +define+NO_CMDS=50

vsim -postsimdataflow -uvmcontrol=all -msgmode both -assertdebug -fsmdebug -classdebug ${gate_sdf_arg} -coverage +cover=bcesxf -c -sv_seed $sv_seed ${plusargs} -sv_lib $DPI_HOME/uvm_dpi +UVM_TESTNAME=${test} -sva -novopt -t 1ps -wlf ${wlf_file} -l ${log_file} ${workdir}.tb_top -do "${exclusion_cmd}coverage save -onexit ${ucdb_file};log -r /*;run -all;quit"
# Note: add wave -r * was filtering all the DUT signals when using pre defined UVM compiled library, log -r /* works like charm.

