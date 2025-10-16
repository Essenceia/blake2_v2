
###########
# Configs #
###########

ifndef debug
#debug :=
endif

# Enable waves by default
ifndef wave
wave:=1
endif

# Coverage, enabled by default
ifndef cov
cov:=1
endif

# Asserts, enabled by default
ifndef assert
assert:=1
endif

# Work in progress flag, used to bypass
# some lint sanity checks during early
# developpement
ifndef wip
wip:=
endif

############
# Sim type #
############

# Define simulator we are using, priority to iverilog
SIM ?= verilator
$(info Using simulator: $(SIM))

###########
# Globals #
###########

# Global configs.
TB_DIR := tb
CONF := conf
WAVE_DIR := wave
DEBUG_FLAG := $(if $(debug), debug=1)
DEFINES := $(if $(wave),wave=1)
WAIVER_FILE := waiver.vlt

########
# Lint #
########

# Lint variables.
LINT_FLAGS :=
ifeq ($(SIM),icarus)
LINT_FLAGS +=-Wall -g2012 $(if $(assert),-gassertions) -gstrict-expr-width
LINT_FLAGS +=$(if $(debug),-DDEBUG) 
else
LINT_FLAGS += -Wall -Wpedantic -Wno-GENUNNAMED -Wno-LATCH -Wno-IMPLICIT
LINT_FLAGS += -Wno-DECLFILENAME
LINT_FLAGS +=$(if $(wip),-Wno-UNUSEDSIGNAL)
endif

# Lint commands.
ifeq ($(SIM),icarus)
define LINT
	mkdir -p build
	iverilog $(LINT_FLAGS) -s $2 -o $(BUILD_DIR)/$2 $1
endef
else
	
define LINT
	mkdir -p build
	verilator $(CONF)/$(WAIVER_FILE) --lint-only $(LINT_FLAGS) $1 --top $2
endef
endif

#########
# Build #
#########

# Build variables.
ifeq ($(SIM),icarus)
BUILD_DIR := build
BUILD_FLAGS := 
else
BUILD_DIR := obj_dir
BUILD_FLAGS := 
BUILD_FLAGS += $(if $(assert),--assert)
BUILD_FLAGS += $(if $(wave), --trace --trace-underscore) 
BUILD_FLAGS += $(if $(cov), --coverage --coverage-underscore) 
BUILD_FLAGS += --timing
BUILD_FLAGS += --x-initial-edge
MAKE_THREADS = 4 
BUILD_FLAGS += -j $(MAKE_THREADS)
endif

# Build commands.
ifeq ($(SIM),icarus)
define BUILD
	mkdir -p build
	iverilog $(LINT_FLAGS) -s $2 -o $(BUILD_DIR)/$2 $1
endef
else
define BUILD
	mkdir -p build
	verilator $(CONF)/$(WAIVER_FILE) --binary $(LINT_FLAGS) $(BUILD_FLAGS) -o $2 $1  
endef
endif

#######
# Run #
#######

# Run commands.
ifeq ($(SIM),icarus)
define RUN
	mkdir -p wave
	vvp $(BUILD_DIR)/$1
endef
else
define RUN
	mkdir -p wave
	./$(BUILD_DIR)/$1 $(if $(wave),+trace) 
endef
endif

config:
	@mkdir -p $(CONF)

build:
	@mkdir -p $(BUILD_DIR)

########
# Lint #
########

entry_deps := $(wildcard *.v)

lint: $(entry_deps)
	$(call LINT,$^,top)

#############
# Testbench #
#############
# Call cocotb
test:
	$(MAKE) -C $(TB_DIR)


# Cleanup
clean:
	rm -f vgcore.* vgd.log*
	rm -f callgrind.out.*
	rm -fr build/*
	rm -fr obj_dir/*
	rm -fr $(WAVE_DIR)/*

