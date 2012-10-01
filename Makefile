export TARGET=iphone:latest:4.2

include $(THEOS)/makefiles/common.mk

SUBPROJECTS += client core support cli

include $(THEOS_MAKE_PATH)/aggregate.mk
