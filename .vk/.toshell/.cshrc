

setenv VIMSHARE $HOME
#setenv VIMSHARE '/usr/share/vim'
setenv PATH '/usr/local/bin/:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin'
source $VIMSHARE/.vk/.kp/bin/setenv.csh
setenv UVM_LIB_HOME /tools/mentor/questa/10.5c/questasim/verilog_src/uvm-1.2/src

alias g gvim -n
alias cl clear
alias c 'clear; ls'
alias b 'cd ..; ls'

alias ktag 'ctags -R -f $HOME/.tags `find $BASE_DIR $UVM_LIB_HOME -regextype sed -regex ".*\.\(vhd\|c\|h\|make\|mak\)\>"` `find $BASE_DIR -iname "makefile"`'
alias ktagsv 'svtags.py -E "\buvm.?(?:-\d+)+" -d $BASE_DIR/.ktagssv $BASE_DIR/'
alias ktaguvm 'svtags.py -d $HOME/.ktagssv $UVM_LIB_HOME/'
alias ktagset 'setenv SVTAGSPATH $BASE_DIR/../.ktagssv:$SVTAGSPATH'


set prompt="%n:%c> "

#------------------------------------------------------------
# EDA Tools
source /tools/source/mentor/cshrc/go_questa_10_5c
source /tools/source/xilinx/cshrc/go_xilinx_2020.1
#source /tools/source/digitaleclairs/cshrc/go_ut
#source /tools/source/diamond/cshrc/lattice
#------------------------------------------------------------

alias spinaldev 'docker run -it --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -p 3389:3389 plex1/spinaldev:latest'

#------------------------------------------------------------
# Scala
setenv JAVA_HOME '/usr/lib/jvm/jre-1.8.0-openjdk'
setenv JRE_HOME '/usr/lib/jvm/jre'
#alias fcer '/opt/freelancer-desktop-app/2.2.0/bin/freelancer-desktop-app &'
#------------------------------------------------------------




