// This feature deliberately persists only in the browser, not on native hosts.
String? readCustomScenario() => null;
void writeCustomScenario(String value) =>
    throw UnsupportedError('Custom scenarios require browser storage');
void removeCustomScenario() {}
