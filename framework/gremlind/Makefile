TARGET = iphone:4.2
TARGET_CXX = xcrun -sdk iphoneos clang++
TARGET_STRIP = ":"

include $(THEOS)/makefiles/common.mk

TOOL_NAME = gremlind
gremlind_FILES = main.m $(wildcard GR*.m)
gremlind_INSTALL_PATH = /Library/Frameworks/Gremlin.framework/Support
gremlind_FRAMEWORKS = MobileCoreServices
gremlind_PRIVATE_FRAMEWORKS = AppSupport
gremlind_CFLAGS += -ggdb -I../ipc

include $(THEOS_MAKE_PATH)/tool.mk

after-gremlind-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/DEBIAN$(ECHO_END)
	$(ECHO_NOTHING)cp scripts/* $(THEOS_STAGING_DIR)/DEBIAN$(ECHO_END)
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/$(ECHO_END)
	$(ECHO_NOTHING)cp -pR LaunchDaemons $(THEOS_STAGING_DIR)/Library/$(ECHO_END)
