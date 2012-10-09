TARGET = iphone:4.2
TARGET_CXX = xcrun -sdk iphoneos clang++

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = Gremlin
Gremlin_FILES = $(wildcard *.m)
Gremlin_FRAMEWORKS = UIKit CoreGraphics
Gremlin_CFLAGS += -FFrameworks
Gremlin_LDFLAGS += -FFrameworks -framework Gremlin

include $(THEOS_MAKE_PATH)/application.mk
