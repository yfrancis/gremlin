TARGET = iphone:4.2
TARGET_CXX = xcrun -sdk iphoneos clang++
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = GRContactImporter
GRContactImporter_FILES = GRContactImporter.m
GRContactImporter_INSTALL_PATH = /Library/Gremlin/Plugins
GRContactImporter_FRAMEWORKS = AddressBook

include $(THEOS_MAKE_PATH)/bundle.mk
