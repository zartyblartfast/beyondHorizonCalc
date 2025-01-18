#!/usr/bin/env pwsh

param(
    [string]$DevBranch = "dev2",                                  # The branch you develop on
    [string]$GhPagesBranch = "gh-pages",                         # The branch that hosts the GitHub Pages
    [string]$TempBuildDir = "C:\Users\clive\VSC\temp_web_build", # Absolute path to temp directory
    [switch]$Force                                                # Force deployment without confirmations
)

# Function to write colored output
function Write-Step {
    param([string]$Message)
    Write-Host "`n>> $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host ">> $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host ">> $Message" -ForegroundColor Red
    exit 1
}

function Restore-InitialState {
    param(
        [string]$OriginalBranch,
        [string]$ErrorMessage
    )
    Write-Host "`n>> Error occurred: $ErrorMessage" -ForegroundColor Red
    Write-Host ">> Attempting to restore initial state..." -ForegroundColor Yellow
    
    # Try to get back to original branch
    if ($OriginalBranch) {
        Write-Host "Switching back to $OriginalBranch..." -ForegroundColor Yellow
        git checkout $OriginalBranch
    }
    
    Write-Host ">> Deployment failed and was safely aborted" -ForegroundColor Red
    Write-Host "Please check the error message above and try again" -ForegroundColor Yellow
    exit 1
}

# Store initial state
$originalBranch = git branch --show-current

Write-Host "`n>> GitHub Pages Deployment Script" -ForegroundColor Cyan
Write-Host "==============================`n" -ForegroundColor Cyan

# Initial Safety Checks
Write-Step "Performing pre-deployment safety checks..."

# 1. Verify git repository
if (-not (Test-Path ".git")) {
    Restore-InitialState -OriginalBranch $originalBranch -ErrorMessage "Not in a git repository"
}

# 2. Check if branches exist
$branches = git branch -a
if (-not ($branches -match $DevBranch)) {
    Restore-InitialState -OriginalBranch $originalBranch -ErrorMessage "Development branch '$DevBranch' not found"
}

# 3. Verify remote connection
try {
    git remote -v | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Restore-InitialState -OriginalBranch $originalBranch -ErrorMessage "No remote repository configured"
    }
} catch {
    Restore-InitialState -OriginalBranch $originalBranch -ErrorMessage "Failed to check remote repository"
}

# 4. Check for uncommitted changes
$status = git status --porcelain
if ($status) {
    Restore-InitialState -OriginalBranch $originalBranch -ErrorMessage "You have uncommitted changes. Please commit or stash them first."
}

# 5. Verify Flutter installation
try {
    flutter --version | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Restore-InitialState -OriginalBranch $originalBranch -ErrorMessage "Flutter not found or not in PATH"
    }
} catch {
    Restore-InitialState -OriginalBranch $originalBranch -ErrorMessage "Flutter not installed or not accessible"
}

# 6. Backup check - ensure dev branch is pushed
$localCommit = git rev-parse $DevBranch
$remoteCommit = git rev-parse origin/$DevBranch
if ($localCommit -ne $remoteCommit) {
    Restore-InitialState -OriginalBranch $originalBranch -ErrorMessage "Local $DevBranch is not in sync with remote. Please push your changes first."
}

# 7. Verify working index.html
$workingIndexPath = Join-Path $PSScriptRoot "..\docs\working_index.html"
if (-not (Test-Path $workingIndexPath)) {
    Restore-InitialState -OriginalBranch $originalBranch -ErrorMessage "Working index.html not found at $workingIndexPath"
}

# 8. Verify temp directory location is safe
if ($TempBuildDir.Contains(".git") -or (Test-Path "$TempBuildDir\.git")) {
    Restore-InitialState -OriginalBranch $originalBranch -ErrorMessage "Temporary directory cannot be within a git repository"
}

# Check if temp directory exists
if (-not (Test-Path $TempBuildDir)) {
    Write-Error "Temp build directory does not exist: $TempBuildDir"
}

# Check if temp directory is not empty
if ((Get-ChildItem -Path $TempBuildDir -Force | Measure-Object).Count -gt 0) {
    if (-not $Force) {
        $confirmation = Read-Host "Temp directory is not empty. Do you want to delete its contents? (y/N)"
        if ($confirmation -ne 'y') {
            Write-Error "Deployment cancelled by user"
        }
    }
    
    # Clean the temp directory
    Write-Step "Cleaning temp directory..."
    try {
        Get-ChildItem -Path $TempBuildDir -Force | ForEach-Object {
            Remove-Item -Path $_.FullName -Force -Recurse
        }
    }
    catch {
        Restore-InitialState -ErrorMessage "Failed to clean temp directory: $_"
    }
}

# Ask for confirmation unless -Force is used
if (-not $Force) {
    Write-Host "`nWARNING: You are about to deploy to GitHub Pages" -ForegroundColor Yellow
    Write-Host "This will:" -ForegroundColor Yellow
    Write-Host "  1. Clean and rebuild the Flutter web app" -ForegroundColor Yellow
    Write-Host "  2. Replace all content in the $GhPagesBranch branch" -ForegroundColor Yellow
    Write-Host "  3. Force push to origin/$GhPagesBranch" -ForegroundColor Yellow
    
    $confirm = Read-Host "`nDo you want to continue? (y/N)"
    if ($confirm -ne "y") {
        Restore-InitialState -OriginalBranch $originalBranch -ErrorMessage "Deployment cancelled by user"
    }
}

# Get repository name from git config for base-href
$repoUrl = git config --get remote.origin.url
$repoName = ($repoUrl -split '/')[-1] -replace '\.git$',''
$baseHref = "/$repoName/"

# Check if we're on the right branch
$currentBranch = git branch --show-current
if ($currentBranch -ne $DevBranch) {
    Restore-InitialState -OriginalBranch $originalBranch -ErrorMessage "Must start from $DevBranch branch. Current branch: $currentBranch"
}

Write-Step "Preparing temporary directory..."

Write-Step "Building Flutter web application..."
try {
    # Clean and rebuild
    flutter clean
    if ($LASTEXITCODE -ne 0) { Restore-InitialState -OriginalBranch $originalBranch -ErrorMessage "Flutter clean failed" }
    
    flutter pub get
    if ($LASTEXITCODE -ne 0) { Restore-InitialState -OriginalBranch $originalBranch -ErrorMessage "Flutter pub get failed" }
    
    Write-Host "Using base-href: $baseHref (matches repository name exactly)"
    flutter build web --release --base-href $baseHref --web-renderer canvaskit
    if ($LASTEXITCODE -ne 0) { Restore-InitialState -OriginalBranch $originalBranch -ErrorMessage "Flutter build failed" }
    
    Write-Success "Flutter build completed"
} catch {
    Restore-InitialState -OriginalBranch $originalBranch -ErrorMessage "Flutter build process failed: $_"
}

Write-Step "Copying build files to temporary location..."
robocopy ".\build\web" $TempBuildDir /E
Write-Success "Build files copied to $TempBuildDir"

Write-Step "Replacing index.html with known working version..."
$workingIndexPath = Join-Path $PSScriptRoot "..\docs\working_index.html"
if (-not (Test-Path $workingIndexPath)) {
    Write-Error "Could not find working index.html at: $workingIndexPath"
}
Copy-Item $workingIndexPath -Destination (Join-Path $TempBuildDir "index.html") -Force
Write-Success "Replaced index.html with dynamic base href version"

Write-Step "Verifying critical files in new build..."
$criticalFiles = @(
    "index.html",
    "main.dart.js",
    "flutter.js",
    "flutter_bootstrap.js",
    "favicon.png",
    "manifest.json"
)

$missingFiles = @()
foreach ($file in $criticalFiles) {
    if (-not (Test-Path "$TempBuildDir\$file")) {
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Restore-InitialState -OriginalBranch $originalBranch -ErrorMessage "Missing critical files in new build: $($missingFiles -join ', ')"
}

Write-Step "Switching to $GhPagesBranch branch..."
git checkout $GhPagesBranch
if ($LASTEXITCODE -ne 0) { Restore-InitialState -OriginalBranch $originalBranch -ErrorMessage "Failed to switch to $GhPagesBranch branch" }

Write-Step "Cleaning $GhPagesBranch branch..."
# First stash any changes in gh-pages branch
git stash -u

# Remove everything except .git directory
Write-Host "Removing existing files (excluding .git)..."
Get-ChildItem -Path . -Exclude '.git' | ForEach-Object {
    try {
        # Try to remove read-only attribute if present
        if (Test-Path $_.FullName -PathType Leaf) {
            Set-ItemProperty $_.FullName -Name IsReadOnly -Value $false -ErrorAction SilentlyContinue
        }
        # Add a small delay to allow any file handles to be released
        Start-Sleep -Milliseconds 100
        Remove-Item $_.FullName -Force -Recurse -ErrorAction Stop
    } catch {
        Write-Host "Warning: Could not remove $($_.FullName): $($_.Exception.Message)" -ForegroundColor Yellow
        # Try one more time after a longer delay
        Start-Sleep -Seconds 1
        try {
            Remove-Item $_.FullName -Force -Recurse -ErrorAction Stop
        } catch {
            Write-Host "Error: Failed to remove file after retry. Continuing anyway..." -ForegroundColor Red
        }
    }
}

Write-Step "Copying new files from temporary directory..."
robocopy $TempBuildDir "." /E
Write-Success "New files copied to $GhPagesBranch branch"

Write-Step "Running deployment verification..."
if (Test-Path ".\scripts\verify_gh_pages_deploy.ps1") {
    . .\scripts\verify_gh_pages_deploy.ps1
    if ($LASTEXITCODE -ne 0) {
        Restore-InitialState -OriginalBranch $originalBranch -ErrorMessage "Verification failed. Please check the errors above."
    }
    Write-Success "Verification passed"
} else {
    Write-Host "Note: Verification script not found - skipping verification" -ForegroundColor Yellow
}

Write-Step "Committing changes..."
git add -A
git commit -m "Deploy to GitHub Pages - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

Write-Step "Pushing to GitHub..."
git push origin $GhPagesBranch --force
if ($LASTEXITCODE -ne 0) { Restore-InitialState -OriginalBranch $originalBranch -ErrorMessage "Failed to push to GitHub" }
Write-Success "Successfully pushed to GitHub"

Write-Step "Cleaning up..."
# Stash any changes before switching back
git stash -u

# Switch back to dev branch
git checkout $DevBranch
if ($LASTEXITCODE -ne 0) { 
    Write-Host "Failed to switch back to $DevBranch - please switch back manually" -ForegroundColor Red
    exit 1
}

Write-Success "Deployment completed successfully!"

$siteUrl = "https://zartyblartfast.github.io/$repoName/"
Write-Host "`nYour site should be live in a few minutes at: $siteUrl" -ForegroundColor Yellow

Write-Host "`nIf you encounter any issues, check:" -ForegroundColor Yellow
Write-Host "1. GitHub Pages settings in your repository" -ForegroundColor Yellow
Write-Host "2. Browser's developer console (F12) for errors" -ForegroundColor Yellow
Write-Host "3. That all files are present in the gh-pages branch" -ForegroundColor Yellow
