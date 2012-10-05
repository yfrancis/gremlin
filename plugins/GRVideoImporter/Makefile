TARGET = iphone:5.0
TARGET_CXX = xcrun -sdk iphoneos clang++
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = GRVideoImporter
GRVideoImporter_FILES = GRVideoImporter.m
GRVideoImporter_INSTALL_PATH = /Library/Gremlin/Plugins
GRVideoImporter_PRIVATE_FRAMEWORKS = PhotoLibraryServices

include $(THEOS_MAKE_PATH)/bundle.mk
