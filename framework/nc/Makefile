include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = nc
nc_FILES = ncController.m
nc_INSTALL_PATH = /Library/WeeLoader/Plugins
nc_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"
