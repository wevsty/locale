cmake_minimum_required(VERSION 3.2)

if(NOT ICU_VERSION)
    message(FATAL_ERROR "ICU_VERSION not set")
endif()
if(NOT ICU_ROOT)
    if(DEFINED ENV{ICU_ROOT}})
        set(ICU_ROOT $ENV{ICU_ROOT})
    else()
        message(FATAL_ERROR "ICU_ROOT not set")
    endif()
endif()

string(REPLACE "." "-" ICU_VERSION_dash ${ICU_VERSION})
string(REPLACE "." "_" ICU_VERSION_under ${ICU_VERSION})
set(ICU_DOWNLOAD_BASE "https://github.com/unicode-org/icu/releases/download")
set(ICU_C_DOWNLOAD_BASE "${ICU_DOWNLOAD_BASE}/release-${ICU_VERSION_dash}/icu4c-${ICU_VERSION_under}")

set(ICU_URLS "")
if(WIN32)
    list(APPEND ICU_URLS "${ICU_C_DOWNLOAD_BASE}-Win32-MSVC2019.zip")
    list(APPEND ICU_URLS "${ICU_C_DOWNLOAD_BASE}-Win64-MSVC2019.zip")
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
    if(ICU_VERSION VERSION_GREATER "71.1")
        list(APPEND ICU_URLS "${ICU_C_DOWNLOAD_BASE}-Ubuntu22.04-x64.tgz")
    else()
        list(APPEND ICU_URLS "${ICU_C_DOWNLOAD_BASE}-Ubuntu20.04-x64.tgz")
    endif()
else()
    message(FATAL_ERROR "Support for this OS(${CMAKE_HOST_SYSTEM_NAME}) not implemented")
endif()

foreach(url IN LISTS ICU_URLS)
    file(TO_NATIVE_PATH "${ICU_ROOT}/icu.zip" archive)
    message(STATUS "Downloading ${url}")
    file(DOWNLOAD "${url}" "${archive}" SHOW_PROGRESS STATUS DOWNLOAD_STATUS)
    list(GET DOWNLOAD_STATUS 0 STATUS_CODE)
    list(GET DOWNLOAD_STATUS 1 ERROR_MESSAGE)
    if(STATUS_CODE EQUAL 0)
        message(STATUS "Download completed successfully!")
    else()
        message(FATAL_ERROR "Error occurred during download: ${ERROR_MESSAGE}")
    endif()
    message(STATUS "Extracting ${archive} to ${ICU_ROOT}")
    if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.18)
        file(ARCHIVE_EXTRACT INPUT "${archive}" DESTINATION "${ICU_ROOT}" VERBOSE)
    else()
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E tar xvf "${archive}"
            WORKING_DIRECTORY "${ICU_ROOT}"
            RESULT_VARIABLE STATUS
        )
        if(STATUS AND NOT STATUS EQUAL 0)
            message(FATAL_ERROR "Extraction failed: ${STATUS}")
        endif()
    endif()
    file(REMOVE "${archive}")
endforeach()

file(GLOB paths ${ICU_ROOT}/*/usr/local/*)
foreach(path IN LISTS paths)
    get_filename_component(folder "${path}" NAME)
    file(RENAME "${path}" "${ICU_ROOT}/${folder}")
endforeach()
