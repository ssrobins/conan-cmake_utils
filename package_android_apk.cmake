function(gradle_build component)
    if(component)
        set(package_name ${component})
    else()
        get_filename_component(package_name ${CPACK_TEMPORARY_DIRECTORY} NAME)
    endif()

    message("\n\nBuilding APK for ${package_name}")

    if(WIN32)
        set(gradle_command gradlew.bat)
        set(gradle_extra_params -Dorg.gradle.daemon.idletimeout=1000)
    else()
        set(gradle_command ./gradlew)
    endif()

    execute_process(
        COMMAND ${gradle_command} assemble${CPACK_BUILD_CONFIG} ${gradle_extra_params}
        WORKING_DIRECTORY ${CPACK_TEMPORARY_DIRECTORY}/${component}
        RESULT_VARIABLE gradle_result
    )
    if(gradle_result)
        message(FATAL_ERROR "Gradle error")
    endif()

    file(GLOB_RECURSE apk_path_original "${CPACK_TEMPORARY_DIRECTORY}/${component}/*.apk")
    set(apk_path_new "${CPACK_TEMPORARY_DIRECTORY}/${component}/${package_name}_${CPACK_ANDROID_ABI}.apk")
    file(RENAME ${apk_path_original} ${apk_path_new})
    file(COPY ${apk_path_new} DESTINATION ${CPACK_PACKAGE_DIRECTORY})

    file(GLOB_RECURSE apk_files
        "${CPACK_TEMPORARY_DIRECTORY}/${component}/app/build/outputs/apk/*.apk"
    )
    file(COPY ${apk_files} DESTINATION ${CPACK_PACKAGE_DIRECTORY})
endfunction(gradle_build)


if(CPACK_COMPONENTS_ALL)
    foreach(component ${CPACK_COMPONENTS_ALL})
        gradle_build(${component})
    endforeach()
else()
    gradle_build("")
endif()
