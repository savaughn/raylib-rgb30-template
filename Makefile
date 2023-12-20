#**************************************************************************************************
#
#   raylib makefile for Desktop platforms, Raspberry Pi, Android and HTML5
#
#   Copyright (c) 2013-2023 Ramon Santamaria (@raysan5)
#
#   This software is provided "as-is", without any express or implied warranty. In no event
#   will the authors be held liable for any damages arising from the use of this software.
#
#   Permission is granted to anyone to use this software for any purpose, including commercial
#   applications, and to alter it and redistribute it freely, subject to the following restrictions:
#
#     1. The origin of this software must not be misrepresented; you must not claim that you
#     wrote the original software. If you use this software in a product, an acknowledgment
#     in the product documentation would be appreciated but is not required.
#
#     2. Altered source versions must be plainly marked as such, and must not be misrepresented
#     as being the original software.
#
#     3. This notice may not be removed or altered from any source distribution.
#
#**************************************************************************************************

.PHONY: all clean

# Define required environment variables
#------------------------------------------------------------------------------------------------
# Define target platform: PLATFORM_DESKTOP, PLATFORM_RPI, PLATFORM_DRM, PLATFORM_ANDROID, PLATFORM_WEB
PLATFORM              ?= PLATFORM_DESKTOP

# Define project variables
PROJECT_NAME          ?= raylib-template
PROJECT_VERSION       := 0.0.1
# prerelease or release
PROJECT_VERSION_TYPE  ?= release

RAYLIB_PATH           ?= libs/raylib

# Locations of raylib.h and libraylib.a/libraylib.so
# NOTE: Those variables are only used for PLATFORM_OS: LINUX, BSD
RAYLIB_INCLUDE_PATH   ?= libs/raylib/include
RAYLIB_LIB_PATH       ?= libs/raylib

# Library type compilation: STATIC (.a) or SHARED (.so/.dll)
RAYLIB_LIBTYPE        ?= STATIC

# Build mode for project: DEBUG or RELEASE
BUILD_MODE            ?= DEBUG

# Use Wayland display server protocol on Linux desktop (by default it uses X11 windowing system)
# NOTE: This variable is only used for PLATFORM_OS: LINUX
USE_WAYLAND_DISPLAY   ?= FALSE

# PLATFORM_WEB: Default properties
BUILD_WEB_ASYNCIFY    ?= FALSE
BUILD_WEB_SHELL       ?= minshell.html
BUILD_WEB_HEAP_SIZE   ?= 134217728
BUILD_WEB_RESOURCES   ?= TRUE
BUILD_WEB_RESOURCES_PATH  ?= resources

# Use cross-compiler for PLATFORM_RPI
ifeq ($(PLATFORM),PLATFORM_RPI)
    USE_RPI_CROSS_COMPILER ?= FALSE
    ifeq ($(USE_RPI_CROSS_COMPILER),TRUE)
        RPI_TOOLCHAIN ?= C:/SysGCC/Raspberry
        RPI_TOOLCHAIN_SYSROOT ?= $(RPI_TOOLCHAIN)/arm-linux-gnueabihf/sysroot
    endif
endif

# Determine PLATFORM_OS in case PLATFORM_DESKTOP selected
ifeq ($(PLATFORM),PLATFORM_DESKTOP)
    # No uname.exe on MinGW!, but OS=Windows_NT on Windows!
    # ifeq ($(UNAME),Msys) -> Windows
    ifeq ($(OS),Windows_NT)
        PLATFORM_OS = WINDOWS
    else
        UNAMEOS = $(shell uname)
        ifeq ($(UNAMEOS),Linux)
            PLATFORM_OS = LINUX
        endif
        ifeq ($(UNAMEOS),FreeBSD)
            PLATFORM_OS = BSD
        endif
        ifeq ($(UNAMEOS),OpenBSD)
            PLATFORM_OS = BSD
        endif
        ifeq ($(UNAMEOS),NetBSD)
            PLATFORM_OS = BSD
        endif
        ifeq ($(UNAMEOS),DragonFly)
            PLATFORM_OS = BSD
        endif
        ifeq ($(UNAMEOS),Darwin)
            PLATFORM_OS = OSX
        endif
    endif
endif
ifeq ($(PLATFORM),PLATFORM_RPI)
    UNAMEOS = $(shell uname)
    ifeq ($(UNAMEOS),Linux)
        PLATFORM_OS = LINUX
    endif
endif
ifeq ($(PLATFORM),PLATFORM_DRM)
    UNAMEOS = $(shell uname)
    ifeq ($(UNAMEOS),Linux)
        PLATFORM_OS = LINUX
    endif
endif

# RAYLIB_PATH adjustment for LINUX platform
# TODO: Do we really need this?
ifeq ($(PLATFORM),PLATFORM_DESKTOP)
    ifeq ($(PLATFORM_OS),LINUX)
        RAYLIB_PREFIX  ?= libs/raylib
        RAYLIB_PATH     = $(realpath $(RAYLIB_PREFIX))
    endif
endif

# Default path for raylib on Raspberry Pi
ifeq ($(PLATFORM),PLATFORM_RPI)
    RAYLIB_PATH        ?= /home/pi/raylib
endif
ifeq ($(PLATFORM),PLATFORM_DRM)
    RAYLIB_PATH        ?= /home/pi/raylib
endif

# Define raylib release directory for compiled library
RAYLIB_RELEASE_PATH 	?= $(RAYLIB_PATH)

ifeq ($(OS),Windows_NT)
    ifeq ($(PLATFORM),PLATFORM_WEB)
        # Emscripten required variables
        EMSDK_PATH         ?= C:/emsdk
        EMSCRIPTEN_PATH    ?= $(EMSDK_PATH)/upstream/emscripten
        CLANG_PATH          = $(EMSDK_PATH)/upstream/bin
        PYTHON_PATH         = $(EMSDK_PATH)/python/3.9.2-1_64bit
        NODE_PATH           = $(EMSDK_PATH)/node/14.15.5_64bit/bin
        export PATH         = $(EMSDK_PATH);$(EMSCRIPTEN_PATH);$(CLANG_PATH);$(NODE_PATH);$(PYTHON_PATH):$$(PATH)
    endif
endif

# Define default C compiler: CC
#------------------------------------------------------------------------------------------------
CC = gcc

ifeq ($(PLATFORM),PLATFORM_DESKTOP)
    ifeq ($(PLATFORM_OS),OSX)
        # OSX default compiler
        CC = clang
    endif
    ifeq ($(PLATFORM_OS),BSD)
        # FreeBSD, OpenBSD, NetBSD, DragonFly default compiler
        CC = clang
    endif
endif
ifeq ($(PLATFORM),PLATFORM_RPI)
    ifeq ($(USE_RPI_CROSS_COMPILER),TRUE)
        # Define RPI cross-compiler
        #CC = armv6j-hardfloat-linux-gnueabi-gcc
        CC = $(RPI_TOOLCHAIN)/bin/arm-linux-gnueabihf-gcc
    endif
endif
ifeq ($(PLATFORM),PLATFORM_WEB)
    # HTML5 emscripten compiler
    # WARNING: To compile to HTML5, code must be redesigned
    # to use emscripten.h and emscripten_set_main_loop()
    CC = emcc
endif

# Define default make program: MAKE
#------------------------------------------------------------------------------------------------
MAKE ?= make

# Define compiler flags: CFLAGS
#------------------------------------------------------------------------------------------------
#  -O1                  defines optimization level
#  -g                   include debug information on compilation
#  -s                   strip unnecessary data from build
#  -Wall                turns on most, but not all, compiler warnings
#  -std=c99             defines C language mode (standard C from 1999 revision)
#  -std=gnu99           defines C language mode (GNU C from 1999 revision)
#  -Wno-missing-braces  ignore invalid warning (GCC bug 53119)
#  -Wno-unused-value    ignore unused return values of some functions (i.e. fread())
#  -D_DEFAULT_SOURCE    use with -std=c99 on Linux and PLATFORM_WEB, required for timespec
CFLAGS = -std=c11 -Wall -Wextra -Wpedantic -Wno-missing-braces -Wunused-result \
            -Wformat=2 -Wno-unused-parameter -Wshadow \
            -Wwrite-strings -Wstrict-prototypes -Wold-style-definition \
            -Wredundant-decls -Wnested-externs -Wmissing-include-dirs -D_DEFAULT_SOURCE

ifeq ($(BUILD_MODE),DEBUG)
    CFLAGS += -g -O2 -D_DEBUG
else
    ifeq ($(PLATFORM),PLATFORM_WEB)
        ifeq ($(BUILD_WEB_ASYNCIFY),TRUE)
            CFLAGS += -O3
        else
            CFLAGS += -Os
        endif
    else
        CFLAGS += -O2
    endif
endif

# Additional flags for compiler (if desired)
#CFLAGS += -Wextra -Wmissing-prototypes -Wstrict-prototypes
ifeq ($(PLATFORM),PLATFORM_DESKTOP)
    ifeq ($(PLATFORM_OS),LINUX)
        ifeq ($(RAYLIB_LIBTYPE),STATIC)
            CFLAGS += -D_DEFAULT_SOURCE -Wjump-misses-init -Wlogical-op 
        endif
        ifeq ($(RAYLIB_LIBTYPE),SHARED)
            # Explicitly enable runtime link to libraylib.so
            CFLAGS += -Wl,-rpath,$(RAYLIB_RELEASE_PATH)
        endif
        CFLAGS += -Wl,-rpath,lib
    endif
endif
ifeq ($(PLATFORM),PLATFORM_RPI)
    CFLAGS += -std=gnu99
endif
ifeq ($(PLATFORM),PLATFORM_DRM)
	CFLAGS += -std=gnu99 -DEGL_NO_X11
	ifeq ($(DEVICE),RGB30)
		CFLAGS += -D__rgb30__
	endif
endif

CFLAGS += -DPROJECT_VERSION=\"$(PROJECT_VERSION)\" -DPROJECT_VERSION_TYPE=\"$(PROJECT_VERSION_TYPE)\"

# Define include paths for required headers: INCLUDE_PATHS
# NOTE: Some external/extras libraries could be required (stb, physac, easings...)
#------------------------------------------------------------------------------------------------
INCLUDE_PATHS = -I. -I$(RAYLIB_PATH)/include

# Define additional directories containing required header files
ifeq ($(PLATFORM),PLATFORM_DESKTOP)
    ifeq ($(PLATFORM_OS),BSD)
        INCLUDE_PATHS += -I$(RAYLIB_INCLUDE_PATH)
    endif
    ifeq ($(PLATFORM_OS),LINUX)
        INCLUDE_PATHS += -I$(RAYLIB_INCLUDE_PATH)
    endif
	ifeq ($(PLATFORM_OS),WINDOWS)
        INCLUDE_PATHS += -Ideps\pksav\include -Ideps\pksav\build\include
    endif
endif
ifeq ($(PLATFORM),PLATFORM_RPI)
    INCLUDE_PATHS += -I$(RPI_TOOLCHAIN_SYSROOT)/opt/vc/include
    INCLUDE_PATHS += -I$(RPI_TOOLCHAIN_SYSROOT)/opt/vc/include/interface/vmcs_host/linux
    INCLUDE_PATHS += -I$(RPI_TOOLCHAIN_SYSROOT)/opt/vc/include/interface/vcos/pthreads
endif
ifeq ($(PLATFORM),PLATFORM_DRM)
    INCLUDE_PATHS += -I/usr/include/libdrm
endif

# Define library paths containing required libs: LDFLAGS
#------------------------------------------------------------------------------------------------
LDFLAGS = -L$(RAYLIB_RELEASE_PATH)

ifeq ($(PLATFORM),PLATFORM_DESKTOP)
    ifeq ($(PLATFORM_OS),WINDOWS)
        # NOTE: The resource .rc file contains windows executable icon and properties
        # LDFLAGS += assets\pkrom.rc.data
        # -Wl,--subsystem,windows hides the console window
        ifeq ($(BUILD_MODE), RELEASE)
            LDFLAGS += -Wl,--subsystem,windows
        endif
    endif
    ifeq ($(PLATFORM_OS),LINUX)
        LDFLAGS += -L$(RAYLIB_LIB_PATH)
    endif
    ifeq ($(PLATFORM_OS),BSD)
        LDFLAGS += -Lsrc -L$(RAYLIB_LIB_PATH)
    endif
endif
ifeq ($(PLATFORM),PLATFORM_WEB)
    # -Os                        # size optimization
    # -O2                        # optimization level 2, if used, also set --memory-init-file 0
    # -s USE_GLFW=3              # Use glfw3 library (context/input management)
    # -s ALLOW_MEMORY_GROWTH=1   # to allow memory resizing -> WARNING: Audio buffers could FAIL!
    # -s TOTAL_MEMORY=16777216   # to specify heap memory size (default = 16MB) (67108864 = 64MB)
    # -s USE_PTHREADS=1          # multithreading support
    # -s WASM=0                  # disable Web Assembly, emitted by default
    # -s ASYNCIFY                # lets synchronous C/C++ code interact with asynchronous JS
    # -s FORCE_FILESYSTEM=1      # force filesystem to load/save files data
    # -s ASSERTIONS=1            # enable runtime checks for common memory allocation errors (-O1 and above turn it off)
    # --profiling                # include information for code profiling
    # --memory-init-file 0       # to avoid an external memory initialization code file (.mem)
    # --preload-file resources   # specify a resources folder for data compilation
    # --source-map-base          # allow debugging in browser with source map
    LDFLAGS += -s USE_GLFW=3 -s TOTAL_MEMORY=$(BUILD_WEB_HEAP_SIZE) -s FORCE_FILESYSTEM=1
    
    # Build using asyncify
    ifeq ($(BUILD_WEB_ASYNCIFY),TRUE)
        LDFLAGS += -s ASYNCIFY
    endif
    
    # Add resources building if required
    ifeq ($(BUILD_WEB_RESOURCES),TRUE)
        LDFLAGS += --preload-file $(BUILD_WEB_RESOURCES_PATH)
    endif
    
    # Add debug mode flags if required
    ifeq ($(BUILD_MODE),DEBUG)
        LDFLAGS += -s ASSERTIONS=1 --profiling
    endif

    # Define a custom shell .html and output extension
    LDFLAGS += --shell-file $(BUILD_WEB_SHELL)
    EXT = .html
endif
ifeq ($(PLATFORM),PLATFORM_RPI)
    LDFLAGS += -L$(RPI_TOOLCHAIN_SYSROOT)/opt/vc/lib
endif

# Define libraries required on linking: LDLIBS
# NOTE: To link libraries (lib<name>.so or lib<name>.a), use -l<name>
#------------------------------------------------------------------------------------------------
ifeq ($(PLATFORM),PLATFORM_DESKTOP)
    ifeq ($(PLATFORM_OS),WINDOWS)
        # Libraries for Windows desktop compilation
        # NOTE: WinMM library required to set high-res timer resolution
        LDLIBS = -lraylib -lopengl32 -lgdi32 -lwinmm
        # Required for physac examples
        LDLIBS += -static -lpthread
    endif
    ifeq ($(PLATFORM_OS),LINUX)
        # Libraries for Debian GNU/Linux desktop compiling
        # NOTE: Required packages: libegl1-mesa-dev
        LDLIBS = -lraylib -lGL -lm -lpthread -ldl -lrt

        # On X11 requires also below libraries
        LDLIBS += -lX11
        # NOTE: It seems additional libraries are not required any more, latest GLFW just dlopen them
        #LDLIBS += -lXrandr -lXinerama -lXi -lXxf86vm -lXcursor

        # On Wayland windowing system, additional libraries requires
        ifeq ($(USE_WAYLAND_DISPLAY),TRUE)
            LDLIBS += -lwayland-client -lwayland-cursor -lwayland-egl -lxkbcommon
        endif
        # Explicit link to libc
        ifeq ($(RAYLIB_LIBTYPE),SHARED)
            LDLIBS += -lc
        endif
    endif
    ifeq ($(PLATFORM_OS),OSX)
        # Libraries for OSX 10.9 desktop compiling
        # NOTE: Required packages: libopenal-dev libegl1-mesa-dev
        LDLIBS = -lraylib -framework OpenGL -framework Cocoa -framework IOKit -framework CoreAudio -framework CoreVideo
    endif
    ifeq ($(PLATFORM_OS),BSD)
        # Libraries for FreeBSD, OpenBSD, NetBSD, DragonFly desktop compiling
        # NOTE: Required packages: mesa-libs
        LDLIBS = -lraylib -lGL -lpthread -lm

        # On XWindow requires also below libraries
        LDLIBS += -lX11 -lXrandr -lXinerama -lXi -lXxf86vm -lXcursor
    endif
endif
ifeq ($(PLATFORM),PLATFORM_RPI)
    # Libraries for Raspberry Pi compiling
    # NOTE: Required packages: libasound2-dev (ALSA)
    LDLIBS = -lraylib -lbrcmGLESv2 -lbrcmEGL -lpthread -lrt -lm -lbcm_host -ldl
    ifeq ($(USE_RPI_CROSS_COMPILER),TRUE)
        LDLIBS += -lvchiq_arm -lvcos
    endif
endif
ifeq ($(PLATFORM),PLATFORM_DRM)
    # Libraries for DRM compiling
    # NOTE: Required packages: libasound2-dev (ALSA)
    LDLIBS = -lraylib -lGLESv2 -lEGL -lpthread -lrt -lm -lgbm -ldrm -ldl
endif
ifeq ($(PLATFORM),PLATFORM_WEB)
    # Libraries for web (HTML5) compiling
    LDLIBS = $(RAYLIB_RELEASE_PATH)/libraylib.a
endif

# Define source code object files required
#------------------------------------------------------------------------------------------------

SOURCE = src
INCLUDE = include
OBJ = obj
$(shell mkdir -p $(OBJ))
$(shell mkdir -p $(OBJ)/screens)
$(shell mkdir -p $(OBJ)/components)
$(shell mkdir -p $(OBJ)/rgb30)
PROJECT_SOURCE_FILES := $(wildcard $(SOURCE)/*.c $(SOURCE)/screens/*.c $(SOURCE)/components/*.c)

ifeq ($(DEVICE),RGB30)
    PROJECT_SOURCE_FILES += $(wildcard $(SOURCE)/rgb30/*.c)
endif

INCLUDE_PATHS += -I$(INCLUDE)

# Define all object files from source files
OBJS = $(patsubst $(SOURCE)/%.c, $(OBJ)/%.o, $(PROJECT_SOURCE_FILES))

# Check if obj directory exists, if not create it
ifeq ($(wildcard $(OBJ)),)
    $(shell mkdir $(OBJ))
endif


# Define processes to execute
#------------------------------------------------------------------------------------------------
# For Android platform we call a custom Makefile.Android
ifeq ($(PLATFORM),PLATFORM_ANDROID)
    MAKEFILE_PARAMS = -f Makefile.Android
    export PROJECT_NAME
    export PROJECT_SOURCE_FILES
else
    MAKEFILE_PARAMS = $(PROJECT_NAME)
endif

# Default target entry
# NOTE: We call this Makefile target or Makefile.Android target
all:
	@mkdir -p build
	@$(MAKE) $(MAKEFILE_PARAMS) -s -B

        # Define the launch target to run the executable
.PHONY: launch
launch:
ifeq ($(filter launch,$(MAKECMDGOALS)),launch)
	$(MAKE) $(MAKEFILE_PARAMS) -s -B && ./build/$(PROJECT_NAME) $(EXT)
endif

rgb30:
	@mkdir -p build
	@$(MAKE) PLATFORM=PLATFORM_DRM DEVICE=RGB30 -s -B

    # Project target defined by PROJECT_NAME
$(PROJECT_NAME): $(OBJS)
	@echo "Building $(PROJECT_NAME)..."
	$(CC) -o build/$(PROJECT_NAME)$(EXT) $(OBJS) $(CFLAGS) $(INCLUDE_PATHS) $(LDFLAGS) $(LDLIBS) -D$(PLATFORM)
	@echo "Build process completed successfully!"

# Compile source files
# NOTE: This pattern will compile every module defined on $(OBJS)
$(OBJ)/%.o: $(SOURCE)/%.c
	$(CC) -c $< -o $@ $(CFLAGS) $(INCLUDE_PATHS) -D$(PLATFORM)

clean:
	@rm -f build/$(PROJECT_NAME)

send:
	sshpass -p $${RGB30_SSH_PASSWORD} scp ./build/$(PROJECT_NAME) root@$${RGB30_SSH_LOCAL_IP}:/roms/ports/$(PROJECT_NAME)/$(PROJECT_NAME)

initialize_rgb30:
	@echo "\nInitializing RGB30..."
	@sshpass -p $${RGB30_SSH_PASSWORD} ssh root@$${RGB30_SSH_LOCAL_IP} "if [ -d /roms/ports/$(PROJECT_NAME) ]; then echo \" - $(PROJECT_NAME) already initialized on device\"; exit 1; fi"
	@sshpass -p $${RGB30_SSH_PASSWORD} ssh root@$${RGB30_SSH_LOCAL_IP} "mkdir -p /roms/ports/$(PROJECT_NAME)"
	@echo " - created $(PROJECT_NAME) directory in ports/"
	@sshpass -p $${RGB30_SSH_PASSWORD} scp resources/$(PROJECT_NAME).sh root@$${RGB30_SSH_LOCAL_IP}:/roms/ports/$(PROJECT_NAME)/$(PROJECT_NAME).sh
	@echo " - copied $(PROJECT_NAME).sh launch script to ports/$(PROJECT_NAME)/"
	@sshpass -p $${RGB30_SSH_PASSWORD} ssh root@$${RGB30_SSH_LOCAL_IP} "sed -i '/<\\/gameList>/i <game><path>/roms/ports/$(PROJECT_NAME)/$(PROJECT_NAME).sh</path><name>$(PROJECT_NAME)</name><desc>$(PROJECT_NAME)</desc></game>' /roms/ports/gamelist.xml"
	@echo " - added $(PROJECT_NAME) to ports/gamelist.xml"
	@echo "RGB30 initialization completed successfully!\n"
	@echo "Refresh your game list on the RGB30 to see $(PROJECT_NAME)"
	@echo "Start > Game Settings > Update Gamelists > Yes"
