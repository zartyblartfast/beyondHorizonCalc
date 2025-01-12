import math

# Constants
R = 6371  # Earth radius in km
h1 = 0.002  # Observer height 2m = 0.002 km
d = 50  # Distance in km
k = 1.07  # Refraction factor

# Adjust radius for refraction
R = R * k

# Method 1: h = d²/(2R)
def calc_method1(d, R):
    return (d * d) / (2 * R)

# Method 2: h = R(1-cos(L₀/R))
def calc_method2(d, R):
    angle = d / R
    return R * (1 - math.cos(angle))

# Calculate using both methods
h2_method1 = calc_method1(d, R)
h2_method2 = calc_method2(d, R)

print(f"Method 1 (d²/2R): {h2_method1:.6f} km")
print(f"Method 2 (R(1-cos(L₀/R))): {h2_method2:.6f} km")
