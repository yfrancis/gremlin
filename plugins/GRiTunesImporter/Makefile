TARGET = iphone:5.0
TARGET_CXX = xcrun -sdk iphoneos clang++
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = GRiTunesImporter
GRiTunesImporter_FILES = $(wildcard *.m)
GRiTunesImporter_INSTALL_PATH = /Library/Gremlin/Plugins
GRiTunesImporter_FRAMEWORKS = AudioToolbox AVFoundation CoreMedia
GRiTunesImporter_PRIVATE_FRAMEWORKS = StoreServices

include $(THEOS_MAKE_PATH)/bundle.mk

