GO_EASY_ON_ME = 1
include theos/makefiles/common.mk

BUNDLE_NAME = GremlinNotify
GremlinNotify_FILES = Tweak.xm
GremlinNotify_FRAMEWORKS = UIKit QuartzCore Gremlin
GremlinNotify_PRIVATE_FRAMEWORKS = BulletinBoard
GremlinNotify_INSTALL_PATH = /Library/WeeLoader/BulletinBoardPlugins
GremlinNotify_CFLAGS = -F$(THEOS)/Frameworks/iphone -I.
GremlinNotify_LDFLAGS = -F$(THEOS)/Frameworks/iphone


include $(THEOS_MAKE_PATH)/bundle.mk
