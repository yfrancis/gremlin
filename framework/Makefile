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
PRODUCT_PATH_ = .products
FMWK_PATH_ = $(PRODUCT_PATH_)/$(FRAMEWORK_NAME).framework
BINARY_DEST_ = $(FMWK_PATH_)/$(FRAMEWORK_NAME)
PROJECT_PATH_ = $(THEOS_PROJECT_DIR)

after-Gremlin-all::
	$(ECHO_NOTHING)mkdir -p Resources/Headers$(ECHO_END)
	$(ECHO_NOTHING)cp -pR include/* Resources/Headers/$(ECHO_END)
	$(ECHO_NOTHING)mkdir -p $(FMWK_PATH_)$(ECHO_END)
	$(ECHO_NOTHING)ln -Fs $(PROJECT_PATH_)/Resources/* $(FMWK_PATH_)/$(ECHO_END)
	$(ECHO_NOTHING)cp $(THEOS_OBJ_DIR)/Gremlin $(BINARY_DEST_)$(ECHO_END)
	$(ECHO_NOTHING)$(TARGET_STRIP) -cx $(BINARY_DEST_)$(ECHO_END)

internal-clean::
	$(ECHO_NOTHING)rm -rf $(PRODUCT_PATH_)$(ECHO_END)
