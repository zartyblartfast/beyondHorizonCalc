import json
import re
import sys
import os
from difflib import SequenceMatcher

def load_presets(json_path: str) -> dict:
    """Load all presets from the presets.json file."""
    with open(json_path, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_presets(json_path: str, data: dict) -> None:
    """Save presets back to the json file."""
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

def load_preset_by_name(json_path: str, preset_name: str) -> tuple:
    """Load a specific preset by its name and return preset and its index."""
    data = load_presets(json_path)
    for i, preset in enumerate(data['presets']):
        if preset['name'] == preset_name:
            return data, preset, i
    return None, None, None

def get_similarity_ratio(str1: str, str2: str) -> float:
    """Get similarity ratio between two strings."""
    return SequenceMatcher(None, str1, str2).ratio()

def find_similar_directories(suggested_name: str, image_dir: str) -> list:
    """Find existing directories with similar names."""
    similar_dirs = []
    if not os.path.exists(image_dir):
        return similar_dirs
        
    for dir_name in os.listdir(image_dir):
        if os.path.isdir(os.path.join(image_dir, dir_name)):
            similarity = get_similarity_ratio(suggested_name, dir_name)
            if similarity > 0.6:  # Threshold for similarity
                similar_dirs.append((dir_name, similarity))
    
    # Sort by similarity ratio in descending order
    return sorted(similar_dirs, key=lambda x: x[1], reverse=True)

def suggest_directory_name(preset_name: str) -> str:
    """Generate a suggested directory name from the preset name."""
    # Handle common separators
    if ' to ' in preset_name:
        parts = preset_name.split(' to ')
    else:
        # If no standard separator, try to split on other patterns
        parts = re.split(r'\s*[-–—]\s*|\s+and\s+|\s*\/\s*', preset_name)
        if len(parts) == 1:  # If still no split, try to split on capital letters
            parts = re.findall('[A-Z][^A-Z]*', preset_name)
    
    if len(parts) < 2:
        return preset_name.lower().replace(' ', '_')
    
    # Clean up each part
    processed_parts = []
    for part in parts[:2]:  # Only take first two parts (observer and target)
        # Remove special characters and extra spaces
        cleaned = re.sub(r'[^\w\s]', '', part)
        # Convert to lowercase and replace spaces with underscores
        cleaned = cleaned.strip().lower().replace(' ', '_')
        processed_parts.append(cleaned)
    
    return '_'.join(processed_parts)

def create_directory_and_update_preset(json_path: str, images_path: str, preset_index: int, 
                                     suggested_dir: str, data: dict) -> None:
    """Create the directory and update the preset's imageDir."""
    # Create the directory
    dir_path = os.path.join(images_path, suggested_dir)
    os.makedirs(dir_path, exist_ok=True)
    print(f"Created directory: {dir_path}")
    
    # Update the preset
    data['presets'][preset_index]['imageDir'] = suggested_dir
    save_presets(json_path, data)
    print(f"Updated preset's imageDir to: {suggested_dir}")

def analyze_preset(preset_name: str) -> None:
    """Analyze a preset and suggest a directory name if needed."""
    json_path = 'assets/info/presets.json'
    images_path = 'assets/images/presets'
    data, preset, preset_index = load_preset_by_name(json_path, preset_name)
    
    if preset is None:
        print(f"Error: Preset '{preset_name}' not found!")
        return
        
    current_dir = preset.get('imageDir', '')
    
    print(f"\nAnalyzing preset: {preset_name}")
    print(f"Current imageDir: {'<empty>' if not current_dir else current_dir}")
    
    if not current_dir:
        suggested_dir = suggest_directory_name(preset_name)
        print(f"Suggested directory name: {suggested_dir}")
        
        # Check if directory already exists
        dir_exists = os.path.exists(os.path.join(images_path, suggested_dir))
        if dir_exists:
            print(f"Note: Directory '{suggested_dir}' already exists!")
        
        # Find similar directory names
        similar_dirs = find_similar_directories(suggested_dir, images_path)
        if similar_dirs:
            print("\nSimilar existing directories found:")
            for dir_name, similarity in similar_dirs:
                similarity_percent = int(similarity * 100)
                print(f"  - {dir_name} ({similarity_percent}% similar)")
        
        if not dir_exists:
            response = input("\nWould you like to create this directory and update the preset? (y/n): ").lower()
            if response == 'y':
                create_directory_and_update_preset(json_path, images_path, preset_index, 
                                                suggested_dir, data)
            else:
                print("Operation cancelled.")
    else:
        print("Directory name already set - no suggestion needed")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python suggest_image_dir.py 'Preset Name'")
        sys.exit(1)
    
    preset_name = ' '.join(sys.argv[1:])
    analyze_preset(preset_name)
