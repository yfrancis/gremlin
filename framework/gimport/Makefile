TARGET = iphone:4.2
include $(THEOS)/makefiles/common.mk

TOOL_NAME = gimport
gimport_FILES = gimport.m
gimport_CFLAGS += -I../include -FFrameworks
gimport_LDFLAGS += -FFrameworks -framework Gremlin
gimport_INSTALL_PATH = /Library/Frameworks/Gremlin.framework/Support

include $(THEOS_MAKE_PATH)/tool.mk
