void main() {
  const double EARTH_RADIUS = 6371000;  // meters
  const double k = 1.07;  // refraction
  const double distance = 50;  // km
  
  // Convert distance to meters
  final double d = distance * 1000;  // = 50,000 meters
  
  // Calculate effective radius
  final double R = EARTH_RADIUS / k;  // = 5,954,205.61 meters
  
  // Calculate hidden height
  final double h = (d * d) / (2 * R);  // meters
  
  print('Distance (m): $d');
  print('Effective radius (m): $R');
  print('Hidden height (m): $h');
  print('Hidden height (km): ${h/1000}');
  
  // Verify with direct calculation
  const num direct = (50000 * 50000) / (2 * (6371000 / 1.07));
  print('\nDirect calculation (m): $direct');
  print('Direct calculation (km): ${direct/1000}');
}
