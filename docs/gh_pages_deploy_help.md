# GitHub Pages Deployment Guide

This document describes how to deploy the Flutter web app to GitHub Pages.

## Prerequisites

1. Ensure you have Git installed and configured
2. Have Flutter installed and configured for web development
3. Create a temporary directory outside your git repository to store build files (e.g., `../temp_web_build`)

## Deployment Steps

### 1. Prepare the Environment

```bash
# Ensure you are on the development branch (dev2)
git checkout dev2
```

### 2. Build the Flutter Web Application

```bash
# Clean the project
flutter clean

# Get dependencies
flutter pub get

# Build web release with correct base href
flutter build web --release --base-href /BeyondHorizonCalc/

# Create a temporary directory and copy build files there
mkdir ../temp_web_build
robocopy "build\web" "..\temp_web_build" /E
```

### 3. Deploy to gh-pages Branch

```bash
# AFTER the web build is complete and files are backed up, switch to gh-pages branch
git checkout gh-pages

# Remove old files (keep .git directory)
git rm -rf .

# Copy new build files from temp directory to ROOT of gh-pages branch
# IMPORTANT: Copy contents of temp_web_build directly to root, not to a subdirectory
robocopy "..\temp_web_build" "." /E

# Clean up temp directory (optional)
rd /s /q "..\temp_web_build"

# Stage new files
git add .

# Commit changes
git commit -m "Update gh-pages with latest web build"

# Push to GitHub (force push is needed as history is different)
git push origin gh-pages --force
```

### 4. Return to Development Branch

```bash
# Switch back to development branch
git checkout dev2
```

## Critical Files Checklist

Before pushing to gh-pages, ensure these critical files are present in the ROOT directory of gh-pages branch:
1. `index.html` - The main entry point for the web app (must be in root directory)
2. `main.dart.js` - The compiled Flutter application
3. `flutter.js` and `flutter_bootstrap.js` - Required Flutter web runtime files
4. `favicon.png` - Web app icon
5. `manifest.json` - Web app manifest file (contains app metadata and icon information)
6. All assets from your assets directory

## Verification Steps

After deployment:
1. Wait a few minutes for GitHub Pages to update (usually 2-5 minutes)
2. Visit your GitHub Pages URL: `https://[username].github.io/BeyondHorizonCalc/`
3. If you see a blank page:
   - Check browser's developer tools (F12) for any console errors
   - Verify that `index.html` exists in the root of gh-pages branch
   - Ensure the `base href` in index.html matches your repository path exactly
   - Confirm all required Flutter web files are present (see Critical Files Checklist)

## Important Notes

1. The temporary directory (`../temp_web_build`) is crucial because:
   - It preserves the build files while switching branches
   - Prevents accidental deletion during the `git rm -rf .` step
   - Ensures a clean deployment without git-related files

2. Always build while on the development branch (dev2) before switching to gh-pages
3. The base-href must match your repository name
4. Force push is necessary on gh-pages as the history is intentionally different

## Custom Domain Configuration

If you're using a custom domain with GitHub Pages, the `index.html` needs special configuration to handle both GitHub Pages and custom domain hosting. Here's the recommended `index.html` configuration:

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="A horizon visibility calculator to show how much of a distant object is hidden by Earth's curvature">

  <!-- iOS meta tags & icons -->
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="Beyond Horizon Calculator">
  <link rel="apple-touch-icon" href="/icons/Icon-192.png">

  <!-- Favicon -->
  <link rel="icon" type="image/png" href="/favicon.png"/>

  <title>Beyond Horizon Calculator</title>
  <link rel="manifest" href="/manifest.json">

  <script>
    // Log current URL info for debugging
    console.log('Protocol:', window.location.protocol);
    console.log('Hostname:', window.location.hostname);
    console.log('Pathname:', window.location.pathname);
    
    // Determine if we're on GitHub Pages
    const isGitHubPages = window.location.hostname === 'zartyblartfast.github.io';
    const basePath = isGitHubPages ? '/beyondHorizonCalc' : '';
    
    // Log the base path
    console.log('Base path:', basePath);
    
    // Function to get correct asset path
    function getAssetPath(path) {
      return basePath + path;
    }
  </script>
</head>
<body>
  <script>
    // Dynamically create and load flutter.js
    const script = document.createElement('script');
    script.src = getAssetPath('/flutter.js');
    script.defer = true;
    script.onload = function() {
      console.log('Flutter.js loaded successfully');
      window._flutter.loader.loadEntrypoint({
        onEntrypointLoaded: async function(engineInitializer) {
          console.log('Flutter engine initializer loaded');
          try {
            const appRunner = await engineInitializer.initializeEngine({
              assetBase: getAssetPath('')
            });
            console.log('Flutter engine initialized');
            await appRunner.runApp();
            console.log('Flutter app started');
          } catch (error) {
            console.error('Error running Flutter app:', error);
          }
        }
      });
    };
    script.onerror = function(error) {
      console.error('Error loading flutter.js:', error);
    };
    document.body.appendChild(script);
  </script>
</body>
</html>
```

## Troubleshooting

If the deployment fails:
1. Ensure all files were copied correctly to the temporary directory
2. Check that no files were accidentally preserved during the cleanup
3. Verify the base-href matches your repository name exactly
4. Make sure you're following the steps in the exact order specified
