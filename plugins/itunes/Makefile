include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = GRiTunesImporter
GRiTunesImporter_FILES = $(wildcard *.m)
GRiTunesImporter_INSTALL_PATH = /Library/Gremlin/Plugins
GRiTunesImporter_FRAMEWORKS = AudioToolbox AVFoundation CoreGraphics UIKit CoreMedia
GRiTunesImporter_PRIVATE_FRAMEWORKS = StoreServices

include $(THEOS_MAKE_PATH)/bundle.mk

SUBPROJECTS += grituneshelper
include $(THEOS_MAKE_PATH)/aggregate.mk
