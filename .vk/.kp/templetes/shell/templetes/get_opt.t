compile_sw=0
sim_sw=0
help_sw=0

test=""
new_test=""
sv_seed=""

cmd_arguments=""

function usage {
  local msg=''
  cat <<EOD
##############################################################################
#                                  HELP                                      #
##############################################################################
#  Description: This script compiles and simulates the
#               UVM Environment
#
#  Command line switches and arguments:
#    Switches:
#      -h = Help
#      -c = Compile
#      -s = Simulate
#    Arguments:
#      new_test       = Add a new testcase to the testcase library
#      test           = Testcase name
#      sv_seed        = Optional, Run a testcase on specific value of SV Seed
#      
#    Usage:
#      ${0##*\/} <Switches> <Arguments>
#
#    For example:
#      ${0##*\/} -cs test=test_sanity
##############################################################################
EOD

  exit 1
}

function get_cmd_switch {
  local OPTIND=1
  while getopts "hcs" sw
  do
    case "${sw}" in
      h) help_sw=1;;
      c) compile_sw=1;;
      s) sim_sw=1;;
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
      *) echo "Error: Unknown argument ${arg%=*}"
         exit 1;;
    esac
  done
}

if [[ "$#" == 0 ]] ; then
  usage
fi

get_cmd_switch $*
get_cmd_arguments $cmd_arguments

if [[ "$help_sw" == 1 ]] ; then
  usage
fi


