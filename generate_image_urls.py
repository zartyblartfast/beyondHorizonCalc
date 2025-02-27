import json
import os
import sys

def load_preset_by_name(json_path: str, preset_name: str) -> dict:
    """Load a specific preset by its name from the presets.json file."""
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
        for preset in data['presets']:
            if preset['name'] == preset_name:
                return preset
    return None

def generate_image_urls(preset_name: str) -> None:
    """Generate GitHub URLs for images in the preset's directory."""
    
    # Constants
    JSON_PATH = 'assets/info/presets.json'
    IMAGES_BASE_PATH = 'assets/images/presets'
    GITHUB_BASE_URL = 'https://raw.githubusercontent.com/zartyblartfast/BeyondHorizonCalc/main/assets/images/presets'
    
    # Load preset
    preset = load_preset_by_name(JSON_PATH, preset_name)
    if not preset:
        print(f"Error: Preset '{preset_name}' not found!")
        sys.exit(1)
    
    # Check imageDir
    image_dir = preset.get('imageDir', '')
    if not image_dir:
        print(f"Error: No imageDir set for preset '{preset_name}'")
        sys.exit(1)
    
    # Check if directory exists
    dir_path = os.path.join(IMAGES_BASE_PATH, image_dir)
    if not os.path.exists(dir_path):
        print(f"Error: Directory not found: {dir_path}")
        sys.exit(1)
    
    # Get list of image files
    image_files = [f for f in os.listdir(dir_path) if f.startswith(('1_', '2_', '3_', '4_'))]
    if not image_files:
        print(f"Error: No image files found in {dir_path}")
        sys.exit(1)
    
    # Generate URLs for each possible image
    urls = {}
    for i in range(1, 5):
        matching_files = [f for f in image_files if f.startswith(f'{i}_')]
        if matching_files:
            url = f"{GITHUB_BASE_URL}/{image_dir}/{matching_files[0]}"
        else:
            url = ""
        urls[f"imageURL_{i}"] = url
        urls[f"imageURL_{i}_source"] = ""  # Initialize source as empty string
    
    # Output JSON format
    print("\nGenerated URLs:")
    print("{")
    for i in range(1, 5):
        key = f"imageURL_{i}"
        source_key = f"imageURL_{i}_source"
        comma = "," if i < 4 or urls[key] else ""
        
        # Print URL
        print(f'    "{key}": "{urls[key]}",')
        # Print source (with comma only if not the last item)
        print(f'    "{source_key}": "{urls[source_key]}"{comma}')
    print("}")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python generate_image_urls.py 'Preset Name'")
        sys.exit(1)
    
    preset_name = ' '.join(sys.argv[1:])
    generate_image_urls(preset_name)
