# Preset System Documentation

## Overview
The preset system in BeyondHorizonCalc provides pre-configured long-distance visibility cases with associated images and information. This document explains how the various components work together.

## Directory Structure
```
BeyondHorizonCalc/
├── assets/
│   ├── images/
│   │   └── presets/
│   │       ├── alto_mora_cristobal_colon/
│   │       ├── alto_mora_la_reina/
│   │       └── ... (other preset directories)
│   └── info/
│       └── presets.json
```

## Components

### 1. presets.json
- Located at `assets/info/presets.json`
- Contains all preset configurations and metadata
- Each preset section includes:
  - Basic information (name, description, heights, distances)
  - Location details (observer and target)
  - Image URLs and their sources
  - Notes and viewing conditions

### 2. Image Directories
- Located under `assets/images/presets/`
- Each preset has its own directory named to match the visibility case
- Standard image files in each directory:
  1. `1_*.jpg` - Main photograph or image of the location
  2. `2_*_map.jpg` - Map showing the line of sight
  3. `3_horizon_diagram.jpg` - Horizon profile diagram
  4. `4_mountain_diagram.jpg` - Mountain profile diagram

### 3. Dropdown Integration

#### Preset Dropdown
- Automatically populated from presets.json
- Lists all available presets by name
- Selecting a preset:
  1. Loads the configuration values
  2. Updates the calculator inputs
  3. Enables the info button ('i' icon)

#### Info Button ('i' icon)
When clicked, displays a modal with:
- All four preset images (if available)
- Image sources (when provided)
- Location details
- Notes and best viewing conditions
- Attribution information

### 4. Report Generation
The menu's report feature uses:
- Current preset configuration
- Associated images
- Calculation results
To generate a comprehensive PDF report including:
- All preset images with sources
- Location details and parameters
- Calculation results and diagrams
- Notes and viewing conditions

## File Naming Conventions
1. Directory names: lowercase with underscores (e.g., `alto_mora_la_reina`)
2. Image files:
   - Numbered prefix to maintain order (1_, 2_, 3_, 4_)
   - Descriptive name in lowercase
   - Standard suffixes (_map, _diagram)
   - Example: `1_alto_mora_la_reina.jpg`

## URL Structure
Image URLs in presets.json follow the pattern:
```
https://raw.githubusercontent.com/zartyblartfast/BeyondHorizonCalc/main/assets/images/presets/[directory]/[filename]
```

## Best Practices
1. Always maintain consistent naming between:
   - Directory names
   - Image filenames
   - JSON URLs
2. Use lowercase for all filenames and directories
3. Include all four standard images when possible
4. Provide image sources when available
5. Keep image sizes reasonable for web loading

## Troubleshooting
If images don't appear in the interface:
1. Check that filenames exactly match the URLs in presets.json
2. Verify the directory structure matches the documentation
3. Ensure all image files are committed and pushed to the repository
4. Check that image file extensions match the URLs (.jpg vs .png)
