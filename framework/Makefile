TARGET = iphone:4.2
include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = Gremlin
Gremlin_FILES = Gremlin.m GRClient.m
Gremlin_CFLAGS += -Iipc
Gremlin_INSTALL_PATH = /Library/Frameworks

SUBPROJECTS = gremlind gimport nc prefs

include $(THEOS_MAKE_PATH)/framework.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-Gremlin-all::
	$(ECHO_NOTHING)mkdir -p gimport/Frameworks/Gremlin.framework/Headers$(ECHO_END)
	$(ECHO_NOTHING)cp Gremlin.h gimport/Frameworks/Gremlin.framework/Headers$(ECHO_END)
	$(ECHO_NOTHING)cp $(THEOS_OBJ_DIR)/Gremlin gimport/Frameworks/Gremlin.framework \
		$(ECHO_END)
	$(ECHO_NOTHING)$(TARGET_STRIP) -cx gimport/Frameworks/Gremlin.framework/Gremlin \
		$(ECHO_END)

