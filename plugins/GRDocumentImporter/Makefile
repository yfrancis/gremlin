export TARGET = iphone:4.2
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = GRDocumentImporter
GRDocumentImporter_FILES = GRDocumentImporter.m
GRDocumentImporter_INSTALL_PATH = /Library/Gremlin/Plugins
GRDocumentImporter_FRAMEWORKS = MobileCoreServices

SUBPROJECTS = redirect

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
