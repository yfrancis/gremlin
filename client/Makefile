TARGET=iphone:4.2
include $(THEOS)/makefiles/common.mk
# .dylib version

 LIBRARY_NAME = libgremlin
 libgremlin_FILES = Gremlin.m GRClient.m
 libgremlin_CFLAGS += -I../include
 
 include $(THEOS_MAKE_PATH)/library.mk
 
 after-libgremlin-all:: 
	-@ cp $(THEOS_OBJ_DIR)/$(THEOS_CURRENT_INSTANCE).dylib $(THEOS)/lib/$(THEOS_CURRENT_INSTANCE).dylib > /dev/null 2>&1
	-@ mkdir -p $(THEOS_INCLUDE_PATH)/extra/Gremlin
	-@ cp Gremlin.h $(THEOS_INCLUDE_PATH)/extra/Gremlin/Gremlin.h > /dev/null 2>&1

