#!/bin/bash


ARGS=""
OUTFILE="$PWD/tags"
MFILE_TOKENS=""
CTAGSFILE=/tmp/.autoctags
CTAGS_OPTIONS=""
MFILES=()

function usage {
  local msg=''
  cat <<EOD
##############################################################################
#                                  HELP                                      #
##############################################################################
#  Description: This script generates the tags for c, matlab, vhdl, make 
#
#  Command line switches and arguments:
#    Switches:
#      -h = Help
#      -f = output file [default := ./tags]
#    Arguments:
#      - List of files and/or directories
#    Usage:
#      ${0##*\/} <Switches> <Arguments>
#
#    For example:
#      ${0##*\/} -f \$HOME/.tags \$BASE_DIR
##############################################################################
EOD

  exit 1
}

function GetOpt {
  local OPTIND=1
  while getopts ":hf:" sw
  do
    case "${sw}" in
      h) usage;;
      f)
        OUTFILE=$(readlink -f $OPTARG)
        ;;
      \?) 
         echo "Invalid option $OPTARG!!!" >&2
         exit 1
         ;;
    esac
  done
  shift $(( OPTIND - 1 ))
  ARGS=$@ 

  if [[ -z "${ARGS}" ]] ; then
    echo "No arguments provided!!! Please use -h option for help."
    exit 1
  fi
}

function join_by {
  sep=$1
  shift
  bar=$(printf "${sep}%s" "$@")
  bar=${bar:${#sep}}

  echo $bar
}

function setMFiles {
  for arg in "$@"
  do
    if [[ -d "${arg}" ]] ; then
      MFILES+="$(find ${arg} -iname '*.m')"
    else
      if [[ ${arg} =~ .*\.m ]] ; then
        MFILES+="$(readlink -f ${arg})"
      fi
    fi
  done
}

function setMFileTokens {
  fbnames=()
  for file in ${MFILES}
  do
    fbname=$(basename ${file} .m)
    fbnames+="$fbname "
  done

  tokens=$(join_by '|' ${fbnames})
  if [[ -n "${tokens}" ]] ; then # Not empty
    tokens="\\<${tokens}\\>"
  fi

  echo "${tokens}"
}

function setMFileTags {
  for file in ${MFILES}
  do
    fbname=$(basename ${file} .m)
    echo "${fbname}	${file}	1;\"	f"
  done
}

#============================================================
# Main
#============================================================

GetOpt $*
setMFiles $ARGS
MFILE_TOKENS=$(setMFileTokens)

if [[ -n "${MFILE_TOKENS}" ]] ; then # Not Empty

cat > $CTAGSFILE <<- EOM

--kinddef-matlab=c,call,script
--_tabledef-matlab=toplevel
--_tabledef-matlab=comment

--_mtable-regex-matlab=toplevel/%\{//{tenter=comment}
--_mtable-regex-matlab=toplevel/(${MFILE_TOKENS})/#call#\\1/c/
--_mtable-regex-matlab=toplevel/.//

--_mtable-regex-matlab=comment/%\}//{tleave}
--_mtable-regex-matlab=comment/.//


EOM

CTAGS_OPTIONS="--options=$CTAGSFILE"

fi

uctags -R -f ${OUTFILE} ${CTAGS_OPTIONS} `find ${ARGS} -regextype sed -regex ".*\.\(vhd\|c\|h\|make\|m\)"` `find ${ARGS} -iname "makefile"`

# Write additional tags to tag file
MFILE_TAGS=$(setMFileTags)
cat >> ${OUTFILE} <<- EOM
${MFILE_TAGS}
EOM

# Sort tag file
vim -N -u NONE -Resnc "sort" +"wqa!" ${OUTFILE}






