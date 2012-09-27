export TARGET=iphone:4.2

include $(THEOS)/makefiles/common.mk

TOOL_NAME = gremlind

gremlind_FILES = main.m $(wildcard GR*.m)
gremlind_FRAMEWORKS = MobileCoreServices
gremlind_PRIVATE_FRAMEWORKS = AppSupport
gremlind_CFLAGS += -I../include -I../SpringBoardAccess

include $(THEOS_MAKE_PATH)/tool.mk
