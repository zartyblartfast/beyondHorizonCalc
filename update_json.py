import json
import os
from collections import OrderedDict

# Read the JSON file
file_path = os.path.join('assets', 'info', 'presets_bigList.json')
with open(file_path, 'r', encoding='utf-8-sig') as f:
    data = json.load(f)

# Function to reorder dictionary to put isHidden after name
def reorder_preset(preset):
    ordered = OrderedDict()
    for key in preset:
        if key == 'name':
            ordered['name'] = preset['name']
            ordered['isHidden'] = True
        elif key != 'isHidden':
            ordered[key] = preset[key]
    return ordered

# Process each preset
data = [reorder_preset(preset) for preset in data]

# Write back to file with proper formatting
with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=4, ensure_ascii=False)
