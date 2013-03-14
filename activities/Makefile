export TARGET = iphone:clang:latest:6.0
export ARCHS = armv7

include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = GRActivities
GRActivities_FILES = $(wildcard *.m)
GRActivities_CFLAGS += -F../framework/_/Library/Frameworks
GRActivities_LDFLAGS += -F../framework/_/Library/Frameworks
GRActivities_FRAMEWORKS = UIKit CoreGraphics MediaPlayer Gremlin

include $(THEOS_MAKE_PATH)/framework.mk
