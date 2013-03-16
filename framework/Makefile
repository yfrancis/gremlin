export TARGET = iphone:clang:latest:4.2

# Support scan-build, which interposes CC/CXX variables
CXX ?= xcrun -sdk iphoneos clang++
CC ?= xcrun -sdk iphoneos clang

export TARGET_CXX = $(CXX)
export TARGET_CC = $(CC)

include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = Gremlin
Gremlin_FILES = $(wildcard *.m)
Gremlin_CFLAGS += -Iipc -Iinclude
Gremlin_FRAMEWORKS = MobileCoreServices
Gremlin_PRIVATE_FRAMEWORKS = AppSupport
Gremlin_INSTALL_PATH = /Library/Frameworks
include $(THEOS)/makefiles/framework.mk

SUBPROJECTS = gremlind gimport prefs
include $(THEOS)/makefiles/aggregate.mk

# Set the paths for the framework stub
PRODUCT_PATH_ = .products/
FMWK_PATH_ = $(PRODUCT_PATH_)/$(FRAMEWORK_NAME).framework
BINARY_DEST_ = $(FMWK_PATH_)/$(FRAMEWORK_NAME)
PROJECT_PATH_ = $(THEOS_PROJECT_DIR)

after-Gremlin-all::
	$(ECHO_NOTHING)cp -a $(THEOS_OBJ_DIR)/Gremlin.framework $(PRODUCT_PATH_)$(ECHO_END)
