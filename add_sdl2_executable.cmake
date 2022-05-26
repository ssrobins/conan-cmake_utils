if(ANDROID)
    find_package(android_sdl2 REQUIRED)
    set(package_root_path ${android_sdl2_PACKAGE_FOLDER_RELEASE})
endif()

function(add_sdl2_executable target_name)
    set(properties ${ARGV})
    list(REMOVE_AT properties 0)
    add_executable_custom(${target_name} ${properties})

    set(androidstudio_path ${CMAKE_BINARY_DIR}/AndroidStudio/${target_name})

    if(ANDROID)
        # Stage copy of gradle project for Android build and SDL's Java files
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E copy_directory
                ${package_root_path}/Android
                ${androidstudio_path}
            COMMAND ${CMAKE_COMMAND} -E copy_directory
                ${CONAN_SDL2_ROOT}/android
                ${androidstudio_path}/app/src/main/java/org/libsdl/app
        )

        # Process files so they include target-specific properties
        configure_file (
            ${package_root_path}/Android/app/src/main/AndroidManifest.xml
            ${androidstudio_path}/app/src/main/AndroidManifest.xml
        )
        if(NOT android_sdk_version)
            message(FATAL_ERROR "Set android_sdk_version CMake variable to the desired target SDK version")
        endif()
        configure_file (
            ${package_root_path}/Android/app/build.gradle
            ${androidstudio_path}/app/build.gradle
        )
        string(REGEX REPLACE "\\\\" "/" ANDROID_NDK_ROOT $ENV{ANDROID_NDK_ROOT})
        string(REGEX REPLACE "\\\\" "/" ANDROID_SDK_ROOT $ENV{ANDROID_SDK_ROOT})
        get_filename_component(cmake_dir "${CMAKE_COMMAND}" DIRECTORY)
        get_filename_component(cmake_dir "${cmake_dir}" DIRECTORY)
        configure_file (
            ${package_root_path}/Android/local.properties
            ${androidstudio_path}/local.properties
        )
        configure_file (
            ${package_root_path}/Android/templates/MainActivity.java
            ${androidstudio_path}/app/src/main/java/com/${company}/${target_name}/MainActivity.java
        )
        configure_file (
            ${package_root_path}/Android/app/src/main/res/values/strings.xml
            ${androidstudio_path}/app/src/main/res/values/strings.xml
        )

        # Copy native library to Android build location
        add_custom_command(
            TARGET ${target_name}
            POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy
                $<TARGET_FILE:${target_name}>
                ${androidstudio_path}/app/src/main/jniLibs/${CMAKE_ANDROID_ARCH_ABI}/$<TARGET_FILE_NAME:${target_name}>
        )
    endif()
endfunction(add_sdl2_executable)
