from conan.tools.cmake import CMake, CMakeDeps, CMakeToolchain
from conans import ConanFile, tools

class Conan(ConanFile):
    name = "cmake_utils"
    version = "1.0.0"
    description = "Shared CMake utilities"
    license = "MIT"
    url = f"https://github.com/ssrobins/conan-{name}"
    settings = "os", "compiler", "build_type", "arch"
    generators = "CMakeDeps"
    revision_mode = "scm"
    exports = "*"
    #build_policy = "missing"

    def generate(self):
        tc = CMakeToolchain(self)
        tc.generate()
        deps = CMakeDeps(self)
        deps.generate()

    def package(self):
        self.copy("*.cmake")
        self.copy("*.in")
        self.copy("*.plist")
        self.copy("*.py")
        self.copy("*.xcsettings")

    def package_info(self):
        self.env_info.PYTHONPATH.append(self.package_folder)
        tools.collect_libs(self)
