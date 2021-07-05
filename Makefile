rwildcard = $(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))
platformpth = $(subst /,$(PATHSEP),$1)

buildDir := bin
executable := app
target := $(buildDir)/$(executable)
sources := $(call rwildcard,src/,*.cpp)
objects := $(patsubst src/%, $(buildDir)/%, $(patsubst %.cpp, %.o, $(sources)))
depends := $(patsubst %.o, %.d, $(objects))

includes := -I vendor/glfw/include -I $(VULKAN_SDK)/include

linkFlags = -L lib/$(platform) -l glfw3 -l vulkan.1 -l vulkan.$(VK_VERSION)
compileFlags := -std=c++17 $(includes)

ifdef MACRO_DEFS
    macroDefines := -D $(MACRO_DEFS)
endif

ifeq (($OS), Windows_NT)

	LIB_EXT = lib
	STATIC_LIB_EXT = lib

	platform := Windows
	CXX ?= g++
	linkFlags += -Wl,--allow-multiple-definition -pthread -lopengl32 -lgdi32 -lwinmm -mwindows -static -static-libgcc -static-libstdc++
	THEN := &&
	PATHSEP := \$(BLANK)
	MKDIR := -mkdir -p
	RM := -del /q
	COPY = -robocopy "$(call platformpth,$1)" "$(call platformpth,$2)" $3

	vulkanLibDir := lib64
	vulkanLib := vulkan-1 
else 
	UNAMEOS := $(shell uname)
	ifeq ($(UNAMEOS), Linux)

		platform := Linux
		CXX ?= g++
		linkFlags += -l GL -l m -l pthread -l dl -l rt -l X11
	endif
	ifeq ($(UNAMEOS), Darwin)

		platform := macOS
		CXX ?= clang++
		linkFlags += -framework CoreVideo -framework IOKit -framework Cocoa -framework GLUT -framework OpenGL

		vulkanExports := export export VK_ICD_FILENAMES=$(VULKAN_SDK)/share/vulkan/icd.d/MoltenVK_icd.json; \ 
						export VK_LAYER_PATH=$(VULKAN_SDK)/share/vulkan/explicit_layer.d
		macOSVulkanLib = $(call COPY, $(VULKAN_SDK)/lib, lib/$(platform),libvulkan.$(VK_VERSION).$(LIB_EXT))
	endif

	LIB_EXT := dylib
	STATIC_LIB_EXT = a

	PATHSEP := /
	MKDIR = mkdir -p
	COPY = cp $1$(PATHSEP)$3 $2
	THEN = ;
	RM := rm -rf

	vulkanLibDir := lib
	vulkanLib := vulkan.1
endif

# Lists phony targets for Makefile
.PHONY: all setup submodules execute clean

all: clear $(target) execute clean

submodules:
	git submodule update --init --recursive

setup: submodules lib

lib:
	cd vendor/glfw $(THEN) cmake . $(THEN) make
	$(MKDIR) $(call platformpth, lib/$(platform))
	$(call COPY, vendor/glfw/src,lib/$(platform),libglfw3.$(STATIC_LIB_EXT))
	$(call COPY, $(VULKAN_SDK)/$(vulkanLibDir),lib/$(platform),lib$(vulkanLib).$(LIB_EXT))
	$(macOSVulkanLib)

# Link the program and create the executable
$(target): $(objects)
	$(CXX) $(objects) -o $(target) $(linkFlags)

# Add all rules from dependency files
-include $(depends)

# Compile objects to the build directory
$(buildDir)/%.o: src/%.cpp Makefile
	$(MKDIR) $(call platformpth, $(@D))
	$(CXX) -MMD -MP -c $(compileFlags) $< -o $@ $(macroDefines)

clear: 
	clear;

execute: 
	$(target) $(ARGS)

clean: 
	$(RM) $(call platformpth, $(buildDir)/*)