class LineOfSightPreset {
  final String name;
  final String description;
  final double observerHeight;
  final double distance;
  final double refractionFactor;
  final double? targetHeight;  // Optional target height

  const LineOfSightPreset({
    required this.name,
    required this.description,
    required this.observerHeight,
    required this.distance,
    required this.refractionFactor,
    this.targetHeight,  // Optional parameter
  });

  static const List<LineOfSightPreset> presets = [
    LineOfSightPreset(
      name: 'Mount Dankova to Hindu Tagh',
      description: 'View from Mount Dankova to Hindu Tagh peak',
      observerHeight: 7015,  // meters
      distance: 539,         // kilometers
      refractionFactor: 1.07,
      targetHeight: 6070,    // Hindu Tagh height in meters
    ),
    LineOfSightPreset(
      name: 'K2 to Broad Peak',
      description: 'View from K2 to Broad Peak',
      observerHeight: 8611,  // meters
      distance: 458,         // kilometers
      refractionFactor: 1.07,
      targetHeight: 8051,    // Broad Peak height in meters
    ),
    LineOfSightPreset(
      name: 'Mount Everest to Kanchenjunga',
      description: 'View from Mount Everest to Kanchenjunga',
      observerHeight: 8848,  // meters
      distance: 380,         // kilometers
      refractionFactor: 1.07,
      targetHeight: 8586,    // Kanchenjunga height in meters
    ),
  ];
}
