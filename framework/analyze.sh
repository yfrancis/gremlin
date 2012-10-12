#!/bin/sh

scan-build --use-analyzer `xcrun -find -sdk iphoneos clang++`\
		   --use-c++ `xcrun -find -sdk iphoneos clang++` \
		   --use-cc `xcrun -find -sdk iphoneos clang` \
		   -k -V \
		   make
