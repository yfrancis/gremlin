TARGET_STRIP = ":"

include $(THEOS)/makefiles/common.mk

TOOL_NAME = gremlind
gremlind_FILES = main.m $(wildcard GR*.m)
gremlind_INSTALL_PATH = /Library/Frameworks/Gremlin.framework/Support.bundle
gremlind_CFLAGS += -ggdb -I../ipc -I../include -F../.products
gremlind_CFLAGS += -F../.products
gremlind_LDFLAGS += -F../.products -framework Gremlin
gremlind_FRAMEWORKS = MobileCoreServices Gremlin
gremlind_PRIVATE_FRAMEWORKS = AppSupport

include $(THEOS_MAKE_PATH)/tool.mk

after-gremlind-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/DEBIAN$(ECHO_END)
	$(ECHO_NOTHING)cp scripts/* $(THEOS_STAGING_DIR)/DEBIAN$(ECHO_END)
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/$(ECHO_END)
	$(ECHO_NOTHING)cp -pR LaunchDaemons $(THEOS_STAGING_DIR)/Library/$(ECHO_END)
	$(ECHO_NOTHING)cp -pR Resources/* \
		$(THEOS_STAGING_DIR)/Library/Frameworks/Gremlin.framework/Support.bundle/\
		$(ECHO_END)
