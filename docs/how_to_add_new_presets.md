# How to Add New Presets

## 1. Research and Verification

Before adding a new preset, complete these research steps:
1. Verify the long-distance line of sight using:
   - Observer Height (h1) in meters
   - Distance (L0) in kilometers
   - Target Height in meters
   - Expected refraction factor (typically 1.07)
2. Confirm what part of the target would be visible
3. Research location details for both observer and target points

Once verified, create a new preset section in `presets.json` using this template:

```json
{
    "name": "Observer to Target",
    "isHidden": false,
    "imageDir": "",
    "description": "View from Observer to Target",
    "observerHeight": 0,
    "distance": 0,
    "refractionFactor": 1.07,
    "targetHeight": 0,
    "details": {
        "location": {
            "observer": {
                "name": "",
                "region": "",
                "country": ""
            },
            "target": {
                "name": "",
                "region": "",
                "country": ""
            }
        },
        "notes": "Line of sight between Observer and Target",
        "bestViewingConditions": "Clear weather with average refraction",
        "imageURL_1": "",
        "imageURL_1_source": "",
        "imageURL_2": "",
        "imageURL_2_source": "",
        "imageURL_3": "",
        "imageURL_3_source": "",
        "imageURL_4": "",
        "imageURL_4_source": "",
        "attribution": ""
    }
}
```

## 2. Creating the Image Directory

After adding the preset to `presets.json`, use the helper script to create and set up the image directory:

```bash
python suggest_image_dir.py "Preset Name"
```

The script will:
1. Suggest a standardized directory name based on the preset name
2. Check for any existing directories with similar names
3. Prompt for confirmation to:
   - Create the directory under `assets/images/presets/`
   - Update the preset's `imageDir` field

Example:
```bash
python suggest_image_dir.py "Teide (corona) to La Palma"
# Output:
# Analyzing preset: Teide (corona) to La Palma
# Current imageDir: <empty>
# Suggested directory name: teide_corona_la_palma
# Would you like to create this directory and update the preset? (y/n):
```

## 3. Adding Required Images

Each preset's image directory should contain exactly 4 images, named using this standard:

1. `1_[target_name].jpg` - Photo of the target location
   - Example: `1_barre_des_ecrins.jpg`

2. `2_[observer]_[target]_map.jpg` - Map showing both locations
   - Example: `2_bastiments_barre_des_ecrins_map.jpg`

3. `3_horizon_diagram.jpg` - Screenshot of the horizon diagram from beyondhorizoncalc.com

4. `4_mountain_diagram.jpg` - Screenshot of the mountain diagram from beyondhorizoncalc.com

## 4. Generating Image URLs

After adding images to the directory, use the helper script to generate the correct GitHub URLs:

```bash
python generate_image_urls.py "Preset Name"
```

The script will:
1. Verify the preset has an `imageDir` set
2. Check that the directory exists
3. Find any images (1-4) present in the directory
4. Generate the correct GitHub URLs for each image found
5. Output JSON-formatted URLs ready to copy into the preset:

```json
{
    "imageURL_1": "https://raw.githubusercontent.com/zartyblartfast/BeyondHorizonCalc/main/assets/images/presets/preset_dir/1_image.jpg",
    "imageURL_1_source": "",
    "imageURL_2": "https://raw.githubusercontent.com/zartyblartfast/BeyondHorizonCalc/main/assets/images/presets/preset_dir/2_map.jpg",
    "imageURL_2_source": "",
    "imageURL_3": "https://raw.githubusercontent.com/zartyblartfast/BeyondHorizonCalc/main/assets/images/presets/preset_dir/3_horizon_diagram.jpg",
    "imageURL_3_source": "",
    "imageURL_4": "https://raw.githubusercontent.com/zartyblartfast/BeyondHorizonCalc/main/assets/images/presets/preset_dir/4_mountain_diagram.jpg",
    "imageURL_4_source": ""
}
```

Copy the generated JSON into the preset's details section in `presets.json`. Add image source URLs as needed.

## 5. Making the Preset Public

The preset and its images become publicly visible on beyondhorizoncalc.com only after:
1. All changes are committed to the repository
2. Changes are merged into the `main` branch
3. The `main` branch is pushed to GitHub

Until then, the preset remains in development and is not accessible to users.

*Note: Additional steps for creating new presets will be added to this document later.*
