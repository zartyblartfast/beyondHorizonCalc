#include "include/clipboard_windows/clipboard_windows_plugin.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <memory>
#include <sstream>

namespace clipboard_windows {

namespace {

using flutter::EncodableMap;
using flutter::EncodableValue;

class ClipboardWindowsPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar) {
    auto channel =
        std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(), "beyond_horizon_calc/clipboard",
            &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<ClipboardWindowsPlugin>();

    channel->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto &call, auto result) {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
  }

  ClipboardWindowsPlugin() {}

  virtual ~ClipboardWindowsPlugin() {}

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    if (method_call.method_name().compare("setRtfClipboard") == 0) {
      const auto* arguments = std::get_if<EncodableMap>(method_call.arguments());
      if (arguments) {
        auto rtf_it = arguments->find(EncodableValue("rtf"));
        if (rtf_it != arguments->end()) {
          const auto& rtf_string = std::get<std::string>(rtf_it->second);
          
          if (OpenClipboard(nullptr)) {
            EmptyClipboard();
            
            // Allocate global memory for RTF content
            size_t size = rtf_string.size() + 1;
            HGLOBAL h_mem = GlobalAlloc(GMEM_MOVEABLE, size);
            if (h_mem) {
              void* mem_ptr = GlobalLock(h_mem);
              if (mem_ptr) {
                memcpy(mem_ptr, rtf_string.c_str(), size);
                GlobalUnlock(h_mem);
                
                // Set RTF format to clipboard
                if (SetClipboardData(RegisterClipboardFormat(L"Rich Text Format"), h_mem)) {
                  CloseClipboard();
                  result->Success();
                  return;
                }
              }
              GlobalFree(h_mem);
            }
            CloseClipboard();
          }
        }
      }
      result->Error("CLIPBOARD_ERROR", "Failed to set RTF clipboard data");
    } else {
      result->NotImplemented();
    }
  }
};

}  // namespace

void ClipboardWindowsPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  ClipboardWindowsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

}  // namespace clipboard_windows
