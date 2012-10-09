export TARGET = iphone:4.2
include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = Gremlin
Gremlin_FILES = $(wildcard *.m)
Gremlin_CFLAGS += -Iipc -Iinclude
Gremlin_FRAMEWORKS = MobileCoreServices
Gremlin_PRIVATE_FRAMEWORKS = AppSupport
Gremlin_INSTALL_PATH = /Library/Frameworks

SUBPROJECTS = gremlind gimport nc prefs

include $(THEOS_MAKE_PATH)/framework.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

# Set the paths for the framework stub
# used by the gimport tool
FMWK_PATH_ = Frameworks/$(FRAMEWORK_NAME).framework
BINARY_DEST_ = $(FMWK_PATH_)/$(FRAMEWORK_NAME)

after-Gremlin-all::
	$(ECHO_NOTHING)mkdir -p Resources/Headers$(ECHO_END)
	$(ECHO_NOTHING)cp include/* Resources/Headers/$(ECHO_END)
	$(ECHO_NOTHING)mkdir -p gimport/$(FMWK_PATH_)$(ECHO_END)
	$(ECHO_NOTHING)cp -pR Resources/* gimport/$(FMWK_PATH_)/$(ECHO_END)
	$(ECHO_NOTHING)cp $(THEOS_OBJ_DIR)/Gremlin gimport/$(FMWK_PATH_)$(ECHO_END)
	$(ECHO_NOTHING)$(TARGET_STRIP) -cx gimport/$(BINARY_DEST_)$(ECHO_END)
	$(ECHO_NOTHING)cp -pR gimport/Frameworks gremlind/$(ECHO_END)
	$(ECHO_NOTHING)cp -pR gimport/Frameworks ../app/$(ECHO_END)

