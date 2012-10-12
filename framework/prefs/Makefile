include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = prefs
prefs_FILES = prefs.mm
prefs_INSTALL_PATH = /Library/PreferenceBundles
prefs_FRAMEWORKS = UIKit
prefs_PRIVATE_FRAMEWORKS = Preferences
prefs_CFLAGS += -Iinclude

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/prefs.plist$(ECHO_END)
