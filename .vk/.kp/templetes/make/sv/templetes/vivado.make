all: clean compile elaborate simulate

TEST=tb_top
LOGDIR=log
LOGNAME=$(TEST)
LOGFILE=$(LOGDIR)/$(LOGNAME)

clean:
	rm -rf work
	mkdir -p $(LOGDIR)

compile:
	xvlog -L uvm -sv -f compile.f

elaborate:
	xelab $(TEST) -debug typical

simulate:
	xsim work.$(TEST) -R







