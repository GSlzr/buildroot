################################################################################
#
# python-sip
#
################################################################################

PYTHON_SIP_VERSION = 4.16
PYTHON_SIP_SOURCE = sip-$(PYTHON_SIP_VERSION).tar.gz
PYTHON_SIP_SITE = http://downloads.sourceforge.net/project/pyqt/sip/sip-$(PYTHON_SIP_VERSION)
PYTHON_SIP_DEPENDENCIES = host-python-sip python
HOST_PYTHON_SIP_DEPENDENCIES = host-python

define HOST_PYTHON_SIP_CONFIGURE_CMDS
    (cd $(@D); \
	$(HOST_CONFIGURE_OPTS) $(HOST_DIR)/usr/bin/python configure.py;\
    )
endef


ifeq ($(BR2_arm)$(BR2_armeb),y)
PYTHON_SIP_PLATFORM = arm
else
PYTHON_SIP_PLATFORM =
endif

define PYTHON_SIP_SET
  $(SED) '/$(1)[[:space:]]/c\$(1) = $(2)' $(3)/specs/linux-$(PYTHON_SIP_PLATFORM)-g++
endef

define PYTHON_SIP_CONFIGURE_CMDS
# Fix compilers path and flags
    $(call PYTHON_SIP_SET,QMAKE_CC,$(TARGET_CC),$(@D))
    $(call PYTHON_SIP_SET,QMAKE_CXX,$(TARGET_CXX),$(@D))
    $(call PYTHON_SIP_SET,QMAKE_LINK,$(TARGET_CXX),$(@D))
    $(call PYTHON_SIP_SET,QMAKE_LINK_SHLIB,$(TARGET_CXX),$(@D))
    $(call PYTHON_SIP_SET,QMAKE_AR,$(TARGET_AR) cqs,$(@D))
    $(call PYTHON_SIP_SET,QMAKE_OBJCOPY,$(TARGET_OBJCOPY),$(@D))
    $(call PYTHON_SIP_SET,QMAKE_RANLIB,$(TARGET_RANLIB),$(@D))
    $(call PYTHON_SIP_SET,QMAKE_STRIP,$(TARGET_STRIP),$(@D))
    $(call PYTHON_SIP_SET,QMAKE_CFLAGS,$(QT_CFLAGS),$(@D))
    $(call PYTHON_SIP_SET,QMAKE_CXXFLAGS,$(QT_CXXFLAGS),$(@D))
    $(call PYTHON_SIP_SET,QMAKE_LFLAGS,$(TARGET_LDFLAGS),$(@D))

    ( cd $(@D); \
	cp specs/linux-$(PYTHON_SIP_PLATFORM)-g++ specs;  \
	$(HOST_DIR)/usr/bin/python configure.py \
		-b $(TARGET_DIR)/usr/bin \
		-d $(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages \
		-e $(STAGING_DIR)/usr/include/python$(PYTHON_VERSION_MAJOR)  \
		-v $(TARGET_DIR)/usr/share/sip \
		-i $(STAGING_DIR)/usr/include/python$(PYTHON_VERSION_MAJOR) \
		-c $(STAGING_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/config \
		-p linux-$(PYTHON_SIP_PLATFORM)-g++; \
    )
endef

define PYTHON_SIP_INSTALL_TARGET_CMDS
    $(TARGET_CONFIGURE_OPTS) $(MAKE) install -C $(@D)
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
