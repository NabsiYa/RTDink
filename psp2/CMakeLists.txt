cmake_minimum_required(VERSION 3.10)

if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
  if(DEFINED ENV{VITASDK})
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VITASDK}/share/vita.toolchain.cmake" CACHE PATH "toolchain file")
  else()
    message(FATAL_ERROR "Please define VITASDK to point to your SDK path!")
  endif()
endif()

ENABLE_LANGUAGE(C)

set(CMAKE_BUILD_TYPE "Debug")

project(RTDink)

include("${VITASDK}/share/vita.cmake" REQUIRED)
include(../../shared/psp2/Proton.cmake)

set(VITA_APP_NAME "RTDink")
set(VITA_TITLEID  "DINK54321")
set(VITA_VERSION  "01.00")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=gnu11")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

proton_include_components(UnpackArchiveComponent)
proton_include_all_components()
proton_use_jpeg_support()
proton_use_linearparticles()
proton_use_sdl_audio()
proton_use_zipfilesystem()
proton_use_ad_framework()

proton_include_gamepad(PSP2 iCade)

set(APP "../source")
set(DINK "${APP}/dink")
set(COMPONENT "${APP}/Component")
set(GUI "${APP}/GUI")

# include headers
include_directories("${APP}")

proton_set_sources("${APP}/App.cpp" "${APP}/video_gl.cpp"
                   "${DINK}/dink.cpp" "${DINK}/FFReader.cpp" "${DINK}/misc_util.cpp" "${DINK}/ScriptAccelerator.cpp" "${DINK}/update_frame.cpp"
                   "${GUI}/AboutMenu.cpp" "${GUI}/BrowseMenu.cpp" "${GUI}/DebugMenu.cpp" "${GUI}/DMODInstallMenu.cpp" "${GUI}/DMODMenu.cpp" "${GUI}/EnterURLMenu.cpp" "${GUI}/ExpiredMenu.cpp" "${GUI}/GameMenu.cpp" "${GUI}/LoadMenu.cpp" "${GUI}/LogMenu.cpp" "${GUI}/MainMenu.cpp" "${GUI}/OptionsMenu.cpp" "${GUI}/PauseMenu.cpp" "${GUI}/PopUpMenu.cpp" "${GUI}/QuickTipMenu.cpp" "${GUI}/ReadTextMenu.cpp"
                   "${COMPONENT}/ActionButtonComponent.cpp" "${COMPONENT}/CursorComponent.cpp" "${COMPONENT}/DragControlComponent.cpp" "${COMPONENT}/FPSControlComponent.cpp" "${COMPONENT}/InventoryComponent.cpp" "${COMPONENT}/EmulatedPointerComponent.cpp")

vita_create_self(eboot.bin ${PROJECT_NAME} UNSAFE)

vita_create_vpk(${PROJECT_NAME}.vpk ${VITA_TITLEID} eboot.bin
  VERSION ${VITA_VERSION}
  NAME ${VITA_APP_NAME}
  FILE ${CMAKE_SOURCE_DIR}/livearea/icon0.png sce_sys/icon0.png
       ${CMAKE_SOURCE_DIR}/livearea/pic0.png sce_sys/pic0.png
       ${CMAKE_SOURCE_DIR}/livearea/bg0.png sce_sys/livearea/contents/bg0.png
       ${CMAKE_SOURCE_DIR}/livearea/startup.png sce_sys/livearea/contents/startup.png
       ${CMAKE_SOURCE_DIR}/livearea/template.xml sce_sys/livearea/contents/template.xml
)

add_custom_target(send
        COMMAND echo destroy | nc 192.168.1.199 1338
        COMMAND curl -T eboot.bin ftp://192.168.1.199:1337/ux0:/app/${VITA_TITLEID}/
        COMMAND echo launch ${VITA_TITLEID} | nc 192.168.1.199 1338
)