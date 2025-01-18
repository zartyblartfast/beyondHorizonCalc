#include "generated_plugin_registrant.h"

#include <clipboard_windows/clipboard_windows_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  ClipboardWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ClipboardWindowsPlugin"));
}
