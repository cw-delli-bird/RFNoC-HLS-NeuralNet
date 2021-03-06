#
# Copyright 2015-2017 Ettus Research
#

# Set IP name
HLS_IP_NAME = ex_iqconv

# Set the include directory
FPGANNET_INCLUDE_DIR = $(FPGANNET_HLS_DIR)/nnet_lib

# Add C/C++/tcl files relative to usrp3/lib/hls/<ip> directory
HLS_IP_$(HLS_IP_NAME)_SRCS = \
$(HLS_IP_NAME).cpp \
$(HLS_IP_NAME).tcl

# Setup build targets, don't remove this
$(eval $(call HLS_IP_GEN_TARGETS,$(HLS_IP_NAME),$(PART_ID),$(HLS_IP_$(HLS_IP_NAME)_SRCS),$(FPGANNET_HLS_DIR),$(IP_BUILD_DIR),$(FPGANNET_INCLUDE_DIR)))
