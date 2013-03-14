export TARGET = iphone:clang:latest:5.0
export ARCHS = armv7

# Support scan-build, which interposes CC/CXX variables
#CXX ?= xcrun -sdk iphoneos clang++
#CC ?= xcrun -sdk iphoneos clang

#export TARGET_CXX = $(CXX)
#export TARGET_CC = $(CC)

include $(THEOS)/makefiles/common.mk

SUBPROJECTS = contacts photos videos itunes

include $(THEOS_MAKE_PATH)/aggregate.mk
