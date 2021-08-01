# location of the Python header files

# BOOST PYTHON
BOOST_INC = /usr/include
BOOST_LIB = /usr/lib

# UCDB
UCDB_INC = /tools/mentor/questa/10.5c/questasim/include
UCDB_LIB = /tools/mentor/questa/10.5c/questasim/linux_x86_64
UCDB_PRINT = ucdb_print

TARGET = ucdb

$(TARGET).so: $(TARGET).o
	g++ -shared -Wl,--export-dynamic \
	$(TARGET).o \
	$(UCDB_PRINT).o -L$(UCDB_LIB) -lucdb \
	-L$(BOOST_LIB) -lboost_python -lboost_regex \
	`python-config --libs` \
	-lsqlite3 \
	-lboost_filesystem -lboost_system \
	-o $(TARGET).so


# -O2                       - Optimize even more.  GCC performs nearly all supported optimizations that do not involve a space-speed tradeoff.
#                           - As compared to -O, this option increases both compilation time and the performance of the generated code.
# -fpic
#                           - Generate position-independent code (PIC) suitable for use in a shared library, if supported for the target machine.  Such code accesses
#                           - all constant addresses through a global offset table (GOT).  The dynamic loader resolves the GOT entries when the program starts (the
#                           - dynamic loader is not part of GCC; it is part of the operating system).  If the GOT size for the linked executable exceeds a machine-
#                           - specific maximum size, you get an error message from the linker indicating that -fpic does not work; in that case, recompile with -fPIC
#                           - instead.  (These maximums are 8k on the SPARC and 32k on the m68k and RS/6000.  The 386 has no such limit.)
#  
# `python-config --cflags`  - Embed python libraries into C (Example -I/usr/include/python2.7 etc...)

$(TARGET).o: $(TARGET).cpp
	g++ -g -O2 -fpic `python-config --cflags` -I$(BOOST_INC) -I$(UCDB_INC) -fPIC -std=c++11 -c $(TARGET).cpp $(UCDB_PRINT).c


clean: 
	rm -rf *.o *.so


