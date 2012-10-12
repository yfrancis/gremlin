include $(THEOS)/makefiles/common.mk

TOOL_NAME = gimport
gimport_FILES = gimport.m
gimport_CFLAGS += -I../include -F../.products
gimport_LDFLAGS += -F../.products -framework Gremlin
gimport_INSTALL_PATH = /usr/local/bin

include $(THEOS_MAKE_PATH)/tool.mk
