all: CLEAN WORK VLOG VOPT VSIM

TEST=tb_top
LOGDIR=log
LOGNAME=$(TEST)
LOGFILE=$(LOGDIR)/$(LOGNAME)
VISUALIZER = 1
SIMTIME=1ms

VSIM_VISUALIZER_OPTIONS=
ifeq ($(VISUALIZER), 1)
	VSIM_VISUALIZER_OPTIONS += -qwavedb=+signal+class+assertion+cells+transaction+uvm_schematic+queue+wavefile=$(LOGFILE)_wave.db+memory=1024,2
endif

VOPT_VISUALIZER_OPTIONS=
ifeq ($(VISUALIZER), 1)
	VOPT_VISUALIZER_OPTIONS += -designfile $(LOGFILE)_design.db
endif

CLEAN:
	rm -rf work
	mkdir -p $(LOGDIR)

WORK:
	vlib work
VLOG:
	vlog -sv -f compile.f -incr

VOPT:
	vopt -mfcu +acc $(VOPT_VISUALIZER_OPTIONS) work.$(TEST) -o $(TEST)_opt +$(TEST).+$(TEST)_opt.

VSIM:
	vsim -c $(TEST)_opt -wlf $(LOGFILE).wlf -l $(LOGFILE).log $(VSIM_VISUALIZER_OPTIONS) -sv_seed 1 -do "log -r /*;run $(SIMTIME);q"

debug:
	visualizer -designfile $(LOGFILE)_design.db -wavefile $(LOGFILE)_wave.db &








