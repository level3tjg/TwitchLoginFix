TARGET := iphone:clang:latest:11.0
INSTALL_TARGET_PROCESSES = Twitch

ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TwitchLoginFix

$(TWEAK_NAME)_FILES = Tweak.x TwitchLoginFixViewController.m
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Iinclude

include $(THEOS_MAKE_PATH)/tweak.mk
