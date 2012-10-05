TARGET = iphone:4.2
TARGET_CXX = xcrun -sdk iphoneos clang++
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = GRPhotoImporter
GRPhotoImporter_FILES = GRPhotoImporter.m
GRPhotoImporter_INSTALL_PATH = /Library/Gremlin/Plugins
GRPhotoImporter_PRIVATE_FRAMEWORKS = PhotoLibrary

include $(THEOS_MAKE_PATH)/bundle.mk
