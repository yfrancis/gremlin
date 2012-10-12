TARGET = iphone:4.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = GRContactImporter
GRContactImporter_FILES = GRContactImporter.m
GRContactImporter_INSTALL_PATH = /Library/Gremlin/Plugins
GRContactImporter_FRAMEWORKS = AddressBook
GRContactImporter_CFLAGS += -Iinclude

include $(THEOS_MAKE_PATH)/bundle.mk
