################################################################################
#
# python-pyqt
#
################################################################################
PYTHON_PYQT_VERSION = 4.10.4
PYTHON_PYQT_SOURCE = PyQt-x11-gpl-$(PYTHON_PYQT_VERSION).tar.gz
PYTHON_PYQT_SITE = http://downloads.sourceforge.net/project/pyqt/PyQt4/PyQt-$(PYTHON_PYQT_VERSION) 
PYTHON_PYQT_DEPENDENCIES = python-sip qt

define PYTHON_PYQT_QTDETAIL
    echo $(1) >> $(2)/qtdetail.out
endef

PYTHON_PYQT_QTDETAIL_LIC = "Open Source"

# ifeq ($(BR2_PACKAGE_QT_LICENSE_APPROVED),y)
#     PYTHON_PYQT_QTDETAIL_LIC = "Open Source"
# else
#     PYTHON_PYQT_QTDETAIL_LIC = ""
# endif

ifeq ($(BR2_PACKAGE_QT_SHARED),y)
    PYTHON_PYQT_QTDETAIL_TYPE = "shared"
else
    PYTHON_PYQT_QTDETAIL_TYPE = ""
endif

# Turn off features that isn't availabe in QWS and current qt configuration.
PYTHON_PYQT_QTDETAIL_DISABLE_FEATURES = PyQt_Accessibility PyQt_SessionManager PyQt_qreal_double PyQt_Shortcut PyQt_RawFont WS_MACX WS_WIN

ifneq ($(BR2_PACKAGE_QT_OPENSSL),y)
    PYTHON_PYQT_QTDETAIL_DISABLE_FEATURES += PyQt_OpenSSL
endif

# Since we can't run generate qtdetail.out by running qtdetail on target device
# we must generate the configuration.
define PYTHON_PYQT_GENERATE_QTDETAIL
    rm -f $(1)/qtdetail.out

    $(call PYTHON_PYQT_QTDETAIL, $(PYTHON_PYQT_QTDETAIL_LIC), $(1))
    $(call PYTHON_PYQT_QTDETAIL, $(PYTHON_PYQT_QTDETAIL_TYPE), $(1))

    for i in $(PYTHON_PYQT_QTDETAIL_DISABLE_FEATURES); do \
        $(call PYTHON_PYQT_QTDETAIL, $$i, $(1)); \
    done
endef

define PYTHON_PYQT_CONFIGURE_CMDS
    $(call PYTHON_PYQT_GENERATE_QTDETAIL, $(@D))

    ( cd $(@D); \
	$(TARGET_CONFIGURE_OPTS) \
	$(HOST_DIR)/usr/bin/python configure-ng.py \
		--bindir $(TARGET_DIR)/usr/bin \
		--destdir $(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages \
		--vendorid-incdir $(STAGING_DIR)/usr/include/python$(PYTHON_VERSION_MAJOR)  \
		--vendorid-libdir $(STAGING_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/config \
		--qmake $(HOST_DIR)/usr/bin/qmake \
		--spec $(BUILD_DIR)/qt-$(QT_VERSION)/mkspecs/qws/linux-$(QT_EMB_PLATFORM)-g++ \
		-w --confirm-license \
		--no-designer-plugin \
		--no-docstrings \
		--no-sip-files \
		--static \
    )
endef

define PYTHON_PYQT_INSTALL_TARGET_CMDS
    $(TARGET_CONFIGURE_OPTS)  $(MAKE) install -C $(@D)
    touch $(TARGET_DIR)/usr/lib/python$(PYTHON_VERSION_MAJOR)/site-packages/PyQt4/__init__.py 
endef

$(eval $(autotools-package))