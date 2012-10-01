TARGET=iphone:4.2
TARGET_CXX = xcrun -sdk iphoneos clang++
TARGET_STRIP="test"
TARGET_STRIP_FLAGS=

include $(THEOS)/makefiles/common.mk

TOOL_NAME = gremlind

gremlind_FILES = main.m $(wildcard GR*.m)
gremlind_INSTALL_PATH = /usr/local/Gremlin
gremlind_FRAMEWORKS = MobileCoreServices
gremlind_PRIVATE_FRAMEWORKS = AppSupport
gremlind_CFLAGS += -ggdb -I../include -I../SpringBoardAccess
gremlind_LDFLAGS += -lBugSense

include $(THEOS_MAKE_PATH)/tool.mk
