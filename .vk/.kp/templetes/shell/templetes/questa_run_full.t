#!/bin/bash
set -e

if [[ -z "${BASE_DIR}" ]] ; then
  dir=`pwd`
  source_dir=${dir%/bin}
  cat <<EOD
Prerequisite: Following steps needs to be performed before this script can be run!!
  \$ cd ${source_dir}
  \$ source startfile
EOD
  exit 1
fi

dut=SFIA

compile_sw=0
cover_sw=0
sim_sw=0
help_sw=0
wlf_sw=0
log_sw=0
debug_sw=0

test=""
new_test=""
sv_seed=""
do=""
max_pass_count=""
sim_type=""

cmd_arguments=""
workdir=""
srcdir=""

function usage {
  local msg=''
  cat <<EOD
##############################################################################
#                                  HELP                                      #
##############################################################################
#  Description: This script compiles and simulates the
#               UVM Environment for SFIA FPGA:
#  Note: The script can be run from any directory.
#
#  Command line switches and arguments:
#    Switches:
#      -h = Help
#      -c = Compile
#      -s = Simulate
#      -l = Open log file in gvim after testcase simulation is completed
#      -w = Open wlf file in modelsim after testcase simulation is completed
#      -v = Generate code coverage report
#      -d = Run vsim in debug mode
#    Arguments:
#      new_test       = Add a new testcase to the testcase library
#      test           = Testcase name
#      sv_seed        = Optional, Run a testcase on specific value of SV Seed
#      do             = This argument is used only with -w switch.
#                       This loads specified do file in modelsim waveform viewer
#      max_pass_count = [Default: 5] Maximum Number of checker PASS messages to be printed.
#                       max_pass_count == 0 to print all the pass messages
#      sim_type       = [Default: RTL] Switch for running RTL vs GATE LEVEL Simulation.
#                       Below values are possible:
#                       RTL: Run RTL simulation.
#                       GATE_MICROSEMI: Run Gate Level simulation for microsemi netlist
#                       GATE_XILINX:    Run Gate Level simulation for xilinx netlist
#      
#    Usage:
#      ${0##*\/} <Switches> <Arguments>
#
#    For example:
#      ${0##*\/} -cs test=sfia_test_sanity
##############################################################################
EOD

  exit 1
}

function get_cmd_switch {
  local OPTIND=1
  while getopts "hcsvwld" sw
  do
    case "${sw}" in
      h) help_sw=1;;
      c) compile_sw=1;;
      v) cover_sw=1;;
      s) sim_sw=1;;
      l) log_sw=1;;
      w) wlf_sw=1;;
      d) debug_sw=1;;
    esac
  done
  shift $(( OPTIND - 1 ))
  cmd_arguments=$*
}

function get_cmd_arguments {
  for arg in "$@"
  do
    case $arg in
      test=*) test=${arg#*=};;
      new_test=*) new_test=${arg#*=};;
      sv_seed=*) sv_seed=${arg#*=};;
      do=*) do=${arg#*=};;
      max_pass_count=*) max_pass_count=${arg#*=};;
      sim_type=*) sim_type=${arg#*=};;
      *) echo "Error: Unknown argument ${arg%=*}"
         exit 1;;
    esac
  done
}

function display_log {
  cat << EOD
# ============================================================
# Log: ${log_file}
# Wlf: ${wlf_file}
# UCDB: ${ucdb_file}
# ============================================================
EOD

}

function set_src_dir {
    workdir=${WORKDIR}/SFIA
    srcdir=${SRCDIR}
}

function compile {
  if [[ "$compile_sw" == 1 ]] ; then
    
    local define="+define+BASE_DIR=\"$BASE_DIR\""

    if [[ ! -d $WORKDIR ]] ; then
      mkdir -p $WORKDIR 
    fi

    if [[ ! -d $LOGDIR ]] ; then
      mkdir -p $LOGDIR 
    fi

    set -xu
    rm -rf ${workdir}
    vlib ${workdir}
    vmap work ${workdir} 
    #vmap work $MTI_HOME/uvm-1.1d/

    if [[ "${sim_type}" == RTL ]] ; then

      echo "Compiling RTL"
      # RTL
      vcom -work ${workdir} $srcdir/6a_HFL_pkg.vhd +cover=cesxf

      vcom -work ${workdir} $srcdir/SFIA_UNFAULTED.vhd +cover=cesxf

      vcom -work ${workdir} $srcdir/5_SFIA.vhd +cover=cesxf

    elif [[ "${sim_type}" == GATE_MICROSEMI ]] ; then

      echo "Compiling Microsemi Netlist "

    elif [[ "${sim_type}" == GATE_XILINX ]] ; then

      echo "Compiling Xilinx netlist"

    fi
    set +xu


    define="${define} +define+${sim_type}=1"

    set -xu
    vlog -64 -work ${workdir} -sv -f $BINDIR/compile.f ${define} 
    set +xu

  fi
}

function open_log {
  if [[ "${log_sw}" == 1 ]] ; then
    gvim "${log_file}"
  fi
}

function open_wlf {
  if [[ "${wlf_sw}" == 1 ]] ; then
    if [[ "${do}" == "" ]] ; then
      vsim -view "${wlf_file}"
    else
      vsim -view "${wlf_file}" -do ${do}
    fi
  fi
}

function simulate {
  if [[ "$sim_sw" == 1 ]] ; then
    if [[ "$test" == "" ]] ; then
      echo "Error: \"test\" argument not provided!!!"
      exit 1
    fi

    timestamp=$(date +"%Y%m%dT%H%M%S")
    runtime_logdir=${LOGDIR}/sfia_${dut}_${timestamp}
    log_file=${runtime_logdir}/$(echo ${dut}| tr '[:upper:]' '[:lower:]')_${test}_${timestamp}.log
    wlf_file=${runtime_logdir}/$(echo ${dut}| tr '[:upper:]' '[:lower:]')_${test}_${timestamp}.wlf
    ucdb_file=${runtime_logdir}/$(echo ${dut}| tr '[:upper:]' '[:lower:]')_${test}_${timestamp}.ucdb
    mkdir "${runtime_logdir}"

    plusargs=""
    if [[ "${max_pass_count}" != "" ]] ; then
      plusargs="${plusargs} +MAX_PASS_COUNT=${max_pass_count}"
    fi

    if [[ "$sv_seed" == "" ]] ; then
      sv_seed=random
    fi

    set -xu

    exclusion_cmd=""
    if [[ "${sim_type}" == RTL ]] ; then
      exclusion_cmd="${exclusion_cmd}do $BINDIR/exclusions/statement_exclusions.do;"
      exclusion_cmd="${exclusion_cmd}do $BINDIR/exclusions/condition_exclusions.do;"
      exclusion_cmd="${exclusion_cmd}do $BINDIR/exclusions/toggle_exclusions.do;"
      exclusion_cmd="${exclusion_cmd}do $BINDIR/exclusions/expression_exclusions.do;"
    fi

    if [[ "$debug_sw" == 1 ]] ; then
      echo "** DEBUG MODE ENABLED"
      vopt -mfcu +acc -debugdb work.tb_top -o tb_top_opt +tb_top.+tb_top_opt.

      vsim -postsimdataflow -uvmcontrol=all -msgmode both -assertdebug -fsmdebug -classdebug -coverage +cover=cesxf -gui -sv_seed $sv_seed ${plusargs} +UVM_TESTNAME=${test} -sva -t 1ps -wlf ${wlf_file} -l ${log_file} work.tb_top_opt -do "${exclusion_cmd}coverage save -onexit ${ucdb_file};run 0;log -r /*;run -all"
      # Note: add wave -r * was filtering all the DUT signals when using pre defined UVM compiled library, log -r * works like charm.

    else
      vsim -coverage +cover=cesxf -c -sv_seed $sv_seed ${plusargs} -sv_lib $DPI_HOME/uvm_dpi +UVM_TESTNAME=${test} -sva -t 1ps -wlf ${wlf_file} -l ${log_file} -novopt  ${workdir}.tb_top -do "${exclusion_cmd}coverage save -onexit ${ucdb_file};log -r /*;run -all;quit"
    fi
    set +xu

    display_log

    open_log
    open_wlf

  fi
}

function generate_cov_report {
  if [[ "${cover_sw}" == 1 ]] ; then
    echo "Generating Coverage Report..."
    vcover report -html ${ucdb_file} -htmldir ${runtime_logdir}/covhtmlreport/
  fi
}

function create_new_test {
  if [[ "${new_test}" != "" ]] ; then
    echo "Creating sequence $SEQDIR/sfia_${new_test}_seq.sv"
    echo "Creating testcase $TESTDIR/sfia_test_${new_test}.sv"
    echo "Updating $SIMDIR/sfia_env_pkg.sv"
    echo "Updating $TESTDIR/sfia_test_pkg.sv"

    cp "$SEQDIR/sfia_###TEMPLATE###_seq.sv" "$SEQDIR/sfia_${new_test}_seq.sv"
    cp "$TESTDIR/sfia_test_###TEMPLATE###.sv" "$TESTDIR/sfia_test_${new_test}.sv"

    sed -i -r "s/TEST_###TEMPLATE###/TEST_\U${new_test}/g" "$TESTDIR/sfia_test_${new_test}.sv"
    sed -i -r "s/###TEMPLATE###/${new_test}/g" "$TESTDIR/sfia_test_${new_test}.sv"
    sed -i -r "s/###TEMPLATE###_SEQ/\U${new_test}_SEQ/g" "$SEQDIR/sfia_${new_test}_seq.sv"
    sed -i -r "s/###TEMPLATE###/${new_test}/g" "$SEQDIR/sfia_${new_test}_seq.sv"

    insert_pattern="### SCRIPT USE ONLY DO NOT REMOVE ###"

    sed -i -r "/${insert_pattern}/ i\`include \"sfia_${new_test}_seq.sv\"" $SIMDIR/sfia_env_pkg.sv
    sed -i -r "/${insert_pattern}/ i\`include \"sfia_test_${new_test}.sv\"" $TESTDIR/sfia_test_pkg.sv

    insert_pattern="<!-- SCRIPT USE ONLY DON'T REMOVE -->"

    echo "Updating $TESTDIR/sfia_test_list.xml"
    sed -i -r "/${insert_pattern}/ i\  <test>\n    <testname>sfia_test_${new_test}</testname>\n  </test>\n" $TESTDIR/sfia_test_list.xml

    exit 0
  fi
}

function check_sim_type {
  if [[ "${sim_type}" == "" ]] ; then
    sim_type=RTL
  fi

  case "${sim_type}" in
    RTL) echo "Note: RTL Simulation is enable";;
    GATE_XILINX) echo "Note: Gate Level Simulatin is enable for Xilinx netlist";;
    GATE_MICROSEMI) echo "Note: Gate Level Simulatin is enable for Microsemi netlist";;
    *) echo "Unknown value sim_type=${sim_type}!!!"
       exit;;
  esac
}


if [[ "$#" == 0 ]] ; then
  usage
fi

get_cmd_switch $*
get_cmd_arguments $cmd_arguments

if [[ "$help_sw" == 1 ]] ; then
  usage
fi

check_sim_type
create_new_test
set_src_dir
compile
simulate
generate_cov_report



















: <<'EOF'
Comment: Copy below commads in startfile to setup the necessory ENV variables
setenv MTI_HOME /eda/apps/unix/sw/mti/10.2c/modeltech/

cd $PWD/../../
setenv BASE_DIR $PWD
cd -

setenv UVM_HOME $MTI_HOME/verilog_src/uvm-1.1d
setenv DPI_HOME $MTI_HOME/../../q10.2c/questa_sim/uvm-1.1d/linux_x86_64/

setenv SRCDIR "$BASE_DIR/fpga/sfia/microsemi/hdl"
setenv SIMDIR "$BASE_DIR/sim/sfia/env/"
setenv SEQDIR "$BASE_DIR/sim/sfia/env/sequences"
setenv TESTDIR "$BASE_DIR/sim/sfia/env/tests"
setenv BINDIR "$BASE_DIR/proc/sfia/bin"
setenv LOGDIR "$BASE_DIR/sim/run/out/"
setenv WORKDIR "$HOME/sim/run/work"
setenv PATH "${PATH}:$BINDIR"
setenv MODELSIM "$BINDIR/modelsim.ini"

alias base "cd $BASE_DIR;clear;ls"
alias src "cd $SRCDIR;clear;ls"
alias sim "cd $SIMDIR;clear;ls"
alias bin "cd $BINDIR;clear;ls"
alias log "cd $LOGDIR;clear;ls"
alias work "cd $WORKDIR;clear;ls"
alias test "cd $TESTDIR;clear;ls"

# setenv PERL5LIB $BASE_DIR/proc/perl_lib/lib/:$BASE_DIR/proc/perl_lib/lib/perl5/:


EOF
















