# Vulkan C++ Starter

Vulkan C++ Starter kit is a simple starter project for the [Vulkan](https://www.vulkan.org/) graphics API. The project automatically pulls down and builds GLFW, whilst also pulling in required libraries from Vulkan. This template does not, however, automate the installation of Vulkan. 

> Why not just use CMake?

I guess we just don't want the added headache. CMake is complex and sometimes feels like some arcane magic that we generally take for granted in build systems. `Vulkan` and `glfw` are fairly standard libraries, and using CMake to link the two feels a little like overkill. The use of a `Makefile` also carried the added advantage of transparency - you know exactly what the compiler is doing, there's no magic involved in this process. 

So that being said, we hope that this repository finds you well and wholeheartedly enjoying the simple things in life (i.e. graphics programming).


### Current Compatibility
| OS          | Default Compiler |  Last Manual Build  |                   Compile Status                     |
| ----------- | ---------------- | ------------------- | ---------------------------------------------------- |
| **macOS**   | Clang++          | `Big Sur 11.4`    | [![macOS](https://github.com/CapsCollective/vulkan-cpp-starter/actions/workflows/macOS.yml/badge.svg)](https://github.com/CapsCollective/vulkan-cpp-starter/actions/workflows/macOS.yml)    |
| **Linux**   | G++              | `Ubuntu-20.04.2.0`  | [![Ubuntu](https://github.com/CapsCollective/vulkan-cpp-starter/actions/workflows/ubuntu.yml/badge.svg)](https://github.com/CapsCollective/vulkan-cpp-starter/actions/workflows/ubuntu.yml)    |
| **Windows** | MinGW (G++)      | `Windows 10 19041`  | [![Windows](https://github.com/CapsCollective/vulkan-cpp-starter/actions/workflows/windows.yml/badge.svg)](https://github.com/CapsCollective/vulkan-cpp-starter/actions/workflows/windows.yml) |

## Getting Started

### Dependencies and Pre-Requisites

Before building the respository, you'll need the following:

1. [CMAKE](https://cmake.org/) - required for building `glfw`.
2. **WINDOWS ONLY**: This project relies primarily on Makefiles for compilation. Our tool of choice for compiling cpp on Windows is [Mingw64](http://mingw-w64.org/doku.php), since it's fully compatible with other operating system compilation methods. A comprehensive guide for installing Mingw64 can be found [here](https://www.youtube.com/watch?v=aXF4A5UeSeM). Once installed, you should be able to pull in your compiler of choice (we recommend gcc or clang).  
3. Vulkan - the SDK can be downloaded from the [LunarG website](https://vulkan.lunarg.com/). 
    
    3.1. Once the Vulkan SDK is installed, you'll want to make sure that both the `VULKAN_SDK` and `VK_VERSION` environment variables are set on your system. Platform specific instructions can be found below:
    
    *  **macOS & Linux:**
        Both MacOS and Linux have a similar process for setting their environment variables. The only difference between the two is their SDK directory structure. The two directory structures have been included below:
        ```bash
        # For macOS
        $ export VULKAN_SDK=<VULKAN_INSTALL_DIR>/VulkanSDK/<VERSION>/macOS\
        # MACOS ONLY MACRO REQUIREMENTS
        $ export VK_ICD_FILENAMES=$VULKAN_SDK/share/vulkan/icd.d/MoltenVK_icd.json
        $ export VK_LAYER_PATH=$VULKAN_SDK/share/vulkan/explicit_layer.d
        
        # for Linux
        $ export VULKAN_SDK=<VULKAN_INSTALL_DIR>/VulkanSDK/<VERSION>/x86_64
        
        # for both
        $ export VK_VERSION=<VERSION>
        ```
        Remember to substitute `<VULKAN_INSTALL_DIR>` with the directory Vulkan was installed into, and `<VERSION>` with your Vulkan version, i.e: 1.2.176.1.
    * **Windows:** 
        For Windows, the SDK should be automatically installed to your `C:` directory. To set these variables, you can set the following:
        ```shell
        > setx VULKAN_SDK = <VULKAN_INSTALL_DIR>/VulkanSDK/<VERSION>
        > setx VK_VERSION = <VERSION>
        ```
        For more information about this syntax, please check the following [guide](https://www.shellhacks.com/windows-set-environment-variable-cmd-powershell/). Environment variables can also be set manually using Windows system properties. 
        
        A guide on this process can be found [here](https://www.alphr.com/environment-variables-windows-10/).

### Building the project
Once you have cloned this repository and installed dependencies, building the project is as simple as running these two commands in its root directory:

#### macOS & Linux
```bash
$ make setup
$ make
```

#### Windows

```shell
> mingw32-make setup
> mingw32-make
```

The first command will pull down the latest version of `glfw`, build it into a static library, and place it in our `lib` folder. This command also pulls in the relevant Vulkan libraries from the Vulkan install location (lucky we set those environment variables earlier!). Finally the last command compiles, runs, and finally cleans up the project. 

*If a blank window pops up then congratulations! You've successfully finished building the project and can now start programming!*

## Using This Template
Now that you have the project setup and compiling on your system, it's time to start programming! If you aren't already familliar with [vulkan](https://vulkan.lunarg.com/), we recommend looking over [this](https://vulkan-tutorial.com/Introduction) amazing tutorial. Vulkan is an incredibly complex but rewarding API. It takes a while to wrap your head around, however, so we thought it might be helpful to look over [this](https://www.jeremyong.com/c++/vulkan/graphics/rendering/2018/03/26/how-to-learn-vulkan/) fantastic article on some good ways to learn Vulkan. 

Once you're up and running, we first of all recommend that all your code for the game should go into the `/src` directory, which is automatically included in the compile process when you run Make. The default entry point for the program is `/src/main.cpp` (which is pretty standard). If you wish to change the program entry point, add more libraries, or really anything about your project, all build instructions are specified in the [`Makefile`](Makefile) - no smoke and mirrors!

### Making Use of Separate Compilation
When building compiled applications from scratch, *each* source file needs to be compiled into an object file in order for them all to be linked together as a full program. This can become rather time-consuming and inefficient as your codebase expands to use tens or even hundreds of files that recompile each time you build. Fortunately, with a few clever rules in our [`Makefile`](Makefile), we can be sure to only have to recompile files affected by our changes.

By using the following Make commands instead of the default target, we can skip the cleanup step, and only recompile files that changed:

#### macOS & Linux

```console
$ make bin/app; make execute
```

#### Windows 
```shell
> mingw32-make bin/app && mingw32-make execute
```


Using this method can save you a huge amount of time compiling *(in reality, just a few seconds)* each time you make a small change to your code! If you want to know more about how it works, you should have a read through [the docs entry explaining the Makefile](https://github.com/CapsCollective/raylib-cpp-starter) from another of our template projects.

While separate compilation works quite well in most scenarios, it's not magic, and there are a few caveats to take note of here:

1. Changing `.h` files will often result in longer compile times by causing all files that include them to recompile
2. Constant changes to files included by many others in your program (like a base-class) will also cause all of those dependent to recompile
3. Including widely-scoped files (like the whole of `vulkan/vulkan.h`) will add all of its own includes as dependent and increase the build time
4. Placing includes in `.h` files instead of forward-declarations will also increase recursive includes and therefore the build time

### Passing Args to the Executable
For working with some projects, you may want to pass arguments to the program once it's been built. This can be achieved by assigning values to the `ARGS` flag in the `Makefile` like below:

#### macOS & Linux

```console
$ make ARGS="--somearg"
```
#### Windows
```shell
> mingw32-make ARGS="--somearg"
```

### Specifying Custom Macro Definitions
You may also want to pass in your own macro definitions for certain configurations (such as setting log levels). You can pass in your definitions using `CXXFLAGS`:


#### macOS & Linux

```console
$ make CXXFLAGS=-DMY_MACRO=1
```

#### Windows
```shell
> mingw32-make CXXFLAGS=-DMY_MACRO=1
```

### Specifying a Non-Default Compiler
If you want to use a compiler for your platform that isn't the default for your system (or potentially you would like to explicitly state it), you can make use of the system-implicit `CXX` variable like so:

#### macOS & Linux

```console
$ make CXX=g++
```

#### Windows
```shell
> mingw32-make CXX=g++
```

## Contributing

### How do I contribute?
It's pretty simple actually:

1. Fork it from [here](https://github.com/CapsCollective/raylib-cpp-starter/fork)
2. Create your feature branch (`git checkout -b cool-new-feature`)
3. Commit your changes (`git commit -m "Added some feature"`)
4. Push to the branch (`git push origin cool-new-feature`)
5. Create a new pull request for it!

### Contributors
- [J-Mo63](https://github.com/J-Mo63) Jonathan Moallem - co-creator, maintainer
- [Raelr](https://github.com/Raelr) Aryeh Zinn - co-creator, maintainer

## Licence

This project is licenced under an unmodified zlib/libpng licence, which is an OSI-certified, BSD-like licence that allows static linking with closed source software. Check [`LICENCE`](LICENSE) for further details.
