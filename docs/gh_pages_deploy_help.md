# GitHub Pages Deployment Guide for Flutter Web

This guide provides step-by-step instructions for deploying a Flutter web application to GitHub Pages, specifically for the BeyondHorizonCalc project.

## Prerequisites

- Git installed and configured
- Flutter SDK installed
- Access to the repository with both `dev2` (or source branch) and `gh-pages` branches

## Deployment Steps

### 1. Ensure Source Branch is Up to Date

```bash
# Switch to source branch (dev2 in this case)
git checkout dev2

# Pull latest changes
git pull origin dev2

# Make sure all changes are committed
git status
git add .
git commit -m "Your commit message"
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
mkdir ..\temp_web_build
robocopy "build\web" "..\temp_web_build" /E
```

### 3. Deploy to gh-pages Branch

```bash
# AFTER the web build is complete and files are backed up, switch to gh-pages branch
git checkout gh-pages

# Remove old files (keep .git directory)
git rm -rf .

# Copy new build files from temp directory
robocopy "..\temp_web_build" "." /E

# Clean up temp directory (optional)
rd /s /q "..\temp_web_build"

# Stage new files
git add .

# Commit changes
git commit -m "Deploy web build"

# Push to remote
git push origin gh-pages
```

### 4. Verify Deployment

1. Go to your repository's Settings
2. Navigate to Pages section
3. Ensure:
   - Source is set to "Deploy from a branch"
   - Branch is set to "gh-pages"
   - Folder is set to "/ (root)"
4. Wait a few minutes for deployment
5. Visit https://[username].github.io/BeyondHorizonCalc/

## Common Issues and Solutions

### 1. Base URL Issues
- Ensure `--base-href` matches your repository name exactly
- For BeyondHorizonCalc, use: `--base-href /BeyondHorizonCalc/`

### 2. Missing Assets
- Verify all assets are properly referenced in `pubspec.yaml`
- Check that all asset paths use forward slashes (/)
- Ensure case sensitivity matches exactly

### 3. Blank Page After Deployment
- Check browser console for 404 errors
- Verify the base href is correct
- Clear browser cache and reload

### 4. Build Artifacts Not Copying
- On Windows, use `robocopy` for reliable copying
- Ensure you're in the correct directory
- Verify build directory exists before copying

## Best Practices

1. Always build from a clean state
2. Commit all source changes before building
3. Test the build locally before deploying
4. Keep the gh-pages branch clean (only built artifacts)
5. Document any custom build configurations

## Rollback Procedure

If deployment fails:

```bash
# Return to previous gh-pages state
git checkout gh-pages
git reset --hard HEAD~1
git push --force origin gh-pages

# Switch back to development
git checkout dev2
```

## Maintenance

- Regularly clean old builds: `flutter clean`
- Update dependencies: `flutter pub upgrade`
- Test deployments in a staging environment first
- Keep documentation updated with any process changes

Remember to replace `BeyondHorizonCalc` with your actual repository name if using this guide for other projects.
