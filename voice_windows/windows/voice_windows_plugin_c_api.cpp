#include "include/voice_windows/voice_windows_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "voice_windows_plugin.h"

void VoiceWindowsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  voice_windows::VoiceWindowsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
