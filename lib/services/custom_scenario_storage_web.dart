import 'package:web/web.dart' as web;

import 'custom_scenario_store.dart';

// Access localStorage inside the callbacks: even getting it can throw when
// browser privacy settings block storage. CustomScenarioStore catches failures.
String? readCustomScenario() =>
    web.window.localStorage.getItem(CustomScenarioStore.storageKey);
void writeCustomScenario(String value) =>
    web.window.localStorage.setItem(CustomScenarioStore.storageKey, value);
void removeCustomScenario() =>
    web.window.localStorage.removeItem(CustomScenarioStore.storageKey);
