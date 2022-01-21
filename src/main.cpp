#define VOLK_IMPLEMENTATION
#include <volk.h>
#include <GLFW/glfw3.h>
#include <iostream>

int main() 
{
    VkResult result = volkInitialize();

    VkInstance instance; 

    volkLoadInstance(instance);

    glfwInit();
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    GLFWwindow* window = glfwCreateWindow(800, 600, "Test Window", nullptr, nullptr);

    uint32_t extensionCount = 0;
    vkEnumerateInstanceExtensionProperties(nullptr, &extensionCount, nullptr);

    std::cout << extensionCount << " extensions supported\n";

    while(!glfwWindowShouldClose(window)) {
        glfwPollEvents();
    }

    glfwDestroyWindow(window);
    glfwTerminate();
}