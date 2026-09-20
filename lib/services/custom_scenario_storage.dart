import 'custom_scenario_store.dart';
import 'custom_scenario_storage_stub.dart'
    if (dart.library.js_interop) 'custom_scenario_storage_web.dart' as platform;

CustomScenarioStore browserCustomScenarioStore() => CustomScenarioStore(
      read: platform.readCustomScenario,
      write: platform.writeCustomScenario,
      remove: platform.removeCustomScenario,
    );
