################################################################################
#
# libretro-ppsspp
#
################################################################################

LIBRETRO_PPSSPP_VERSION = v1.19.3
LIBRETRO_PPSSPP_SITE = https://github.com/hrydgard/ppsspp.git
LIBRETRO_PPSSPP_SITE_METHOD=git
LIBRETRO_PPSSPP_GIT_SUBMODULES=YES
LIBRETRO_PPSSPP_LICENSE = GPLv2
LIBRETRO_PPSSPP_DEPENDENCIES += retroarch

LIBRETRO_PPSSPP_CMAKE_BACKEND = ninja

LIBRETRO_PPSSPP_CONF_OPTS += -DCMAKE_BUILD_TYPE=Release
LIBRETRO_PPSSPP_CONF_OPTS += -DBUILD_SHARED_LIBS=OFF
LIBRETRO_PPSSPP_CONF_OPTS += -DCMAKE_SYSTEM_NAME=Linux
LIBRETRO_PPSSPP_CONF_OPTS += -DLIBRETRO=ON
LIBRETRO_PPSSPP_CONF_OPTS += -DANDROID=OFF
LIBRETRO_PPSSPP_CONF_OPTS += -DWIN32=OFF
LIBRETRO_PPSSPP_CONF_OPTS += -DAPPLE=OFF
LIBRETRO_PPSSPP_CONF_OPTS += -DUSE_FFMPEG=ON
LIBRETRO_PPSSPP_CONF_OPTS += -DUSE_SYSTEM_FFMPEG=OFF
LIBRETRO_PPSSPP_CONF_OPTS += -DUSE_DISCORD=OFF
LIBRETRO_PPSSPP_CONF_OPTS += -DUSING_FBDEV=OFF
LIBRETRO_PPSSPP_CONF_OPTS += -DUNITTEST=OFF
LIBRETRO_PPSSPP_CONF_OPTS += -DSIMULATOR=OFF
LIBRETRO_PPSSPP_CONF_OPTS += -DENABLE_CTEST=OFF

LIBRETRO_PPSSPP_TARGET_CFLAGS = $(TARGET_CFLAGS)

ifeq ($(BR2_PACKAGE_VULKAN_HEADERS)$(BR2_PACKAGE_VULKAN_LOADER),yy)
    LIBRETRO_PPSSPP_CONF_OPTS += -DVULKAN=ON
else
    LIBRETRO_PPSSPP_CONF_OPTS += -DVULKAN=OFF
endif

# enable wayland/vulkan interface only if wayland
ifeq ($(BR2_PACKAGE_BATOCERA_WAYLAND),y)
    LIBRETRO_PPSSPP_CONF_OPTS += -DUSE_WAYLAND_WSI=ON
else
    LIBRETRO_PPSSPP_CONF_OPTS += -DUSE_WAYLAND_WSI=OFF
endif

# enable x11/vulkan interface only if xorg
ifeq ($(BR2_PACKAGE_XSERVER_XORG_SERVER),y)
    LIBRETRO_PPSSPP_CONF_OPTS += -DUSING_X11_VULKAN=ON
else
    LIBRETRO_PPSSPP_CONF_OPTS += -DUSING_X11_VULKAN=OFF
    LIBRETRO_PPSSPP_TARGET_CFLAGS += -DEGL_NO_X11=1 -DMESA_EGL_NO_X11_HEADERS=1
endif

# arm
ifeq ($(BR2_arm),y)
    LIBRETRO_PPSSPP_DEPENDENCIES += libgles
    LIBRETRO_PPSSPP_CONF_OPTS += -DARM=ON
    LIBRETRO_PPSSPP_CONF_OPTS += -DARMV7=ON
    LIBRETRO_PPSSPP_CONF_OPTS += -DUSING_GLES2=ON
    LIBRETRO_PPSSPP_CONF_OPTS += -DUSING_EGL=ON
endif

ifeq ($(BR2_aarch64),y)
    LIBRETRO_PPSSPP_DEPENDENCIES += libgles
    LIBRETRO_PPSSPP_CONF_OPTS += -DARM=ON
    LIBRETRO_PPSSPP_CONF_OPTS += -DARM64=ON
    LIBRETRO_PPSSPP_CONF_OPTS += -DUSING_GLES2=ON
    LIBRETRO_PPSSPP_CONF_OPTS += -DUSING_EGL=ON
endif

# riscv
ifeq ($(BR2_riscv),y)
    LIBRETRO_PPSSPP_DEPENDENCIES += libgles
    LIBRETRO_PPSSPP_CONF_OPTS += -DRISCV=ON
    LIBRETRO_PPSSPP_CONF_OPTS += -DRISCV64=ON
    LIBRETRO_PPSSPP_CONF_OPTS += -DUSING_GLES2=ON
    LIBRETRO_PPSSPP_CONF_OPTS += -DUSING_EGL=OFF
endif

# x86_64
ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_X86_64_ANY),y)
    LIBRETRO_PPSSPP_DEPENDENCIES += libgl
    LIBRETRO_PPSSPP_CONF_OPTS += -DX86_64=ON
endif

ifeq ($(BR2_PACKAGE_HAS_LIBMALI),y)
    LIBRETRO_PPSSPP_DEPENDENCIES += libmali
    LIBRETRO_PPSSPP_CONF_OPTS += -DCMAKE_EXE_LINKER_FLAGS=-lmali
    LIBRETRO_PPSSPP_CONF_OPTS += -DCMAKE_SHARED_LINKER_FLAGS=-lmali
endif

LIBRETRO_PPSSPP_CONF_OPTS += -DCMAKE_C_FLAGS="$(LIBRETRO_PPSSPP_TARGET_CFLAGS)"
LIBRETRO_PPSSPP_CONF_OPTS += -DCMAKE_CXX_FLAGS="$(LIBRETRO_PPSSPP_TARGET_CFLAGS)"

define LIBRETRO_PPSSPP_UPDATE_INCLUDES
	sed -i 's/unknown/"$(shell echo $(LIBRETRO_PPSSPP_VERSION) | cut -c 1-7)"/g' \
        $(@D)/git-version.cmake
	sed -i "s+/opt/vc+$(STAGING_DIR)/usr+g" $(@D)/CMakeLists.txt
endef

LIBRETRO_PPSSPP_PRE_CONFIGURE_HOOKS += LIBRETRO_PPSSPP_UPDATE_INCLUDES

define LIBRETRO_PPSSPP_INSTALL_TARGET_CMDS
    $(INSTALL) -D $(@D)/lib/ppsspp_libretro.so \
		$(TARGET_DIR)/usr/lib/libretro/ppsspp_libretro.so

    # Required for game menus
    mkdir -p $(TARGET_DIR)/usr/share/ppsspp
	cp -R $(@D)/assets $(TARGET_DIR)/usr/share/ppsspp/PPSSPP
endef

$(eval $(cmake-package))
