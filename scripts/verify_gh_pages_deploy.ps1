#!/usr/bin/env pwsh

Write-Host "`n🔍 GitHub Pages Deployment Verification Script" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

# Get repository name from git config
$repoUrl = git config --get remote.origin.url
$repoName = ($repoUrl -split '/')[-1] -replace '\.git$',''

Write-Host "📁 Repository Name: $repoName" -ForegroundColor Yellow

# Check if we're on gh-pages branch
$currentBranch = git branch --show-current
if ($currentBranch -ne "gh-pages") {
    Write-Host "❌ Error: Must be on gh-pages branch. Current branch: $currentBranch" -ForegroundColor Red
    exit 1
}

# Critical files to check
$criticalFiles = @(
    "index.html",
    "main.dart.js",
    "flutter.js",
    "flutter_bootstrap.js",
    "favicon.png",
    "manifest.json"
)

Write-Host "`n📋 Checking Critical Files..." -ForegroundColor Cyan
$missingFiles = @()
foreach ($file in $criticalFiles) {
    if (Test-Path $file) {
        Write-Host "✅ Found: $file" -ForegroundColor Green
    } else {
        Write-Host "❌ Missing: $file" -ForegroundColor Red
        $missingFiles += $file
    }
}

# Check base href in index.html
if (Test-Path "index.html") {
    $indexContent = Get-Content "index.html" -Raw
    $baseHref = [regex]::Match($indexContent, '<base href="([^"]+)"').Groups[1].Value
    $expectedBaseHref = "/$repoName/"
    
    Write-Host "`n🔍 Checking base href..." -ForegroundColor Cyan
    Write-Host "Found:    $baseHref" -ForegroundColor Yellow
    Write-Host "Expected: $expectedBaseHref" -ForegroundColor Yellow
    
    if ($baseHref -cne $expectedBaseHref) {
        Write-Host "❌ Error: base href case mismatch!" -ForegroundColor Red
        Write-Host "Please update index.html to use exactly: <base href=`"$expectedBaseHref`">" -ForegroundColor Red
    } else {
        Write-Host "✅ base href matches repository name (case-sensitive)" -ForegroundColor Green
    }
}

# Summary
Write-Host "`n📊 Verification Summary" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan

if ($missingFiles.Count -eq 0 -and $baseHref -ceq $expectedBaseHref) {
    Write-Host "✅ All checks passed! Safe to push to GitHub Pages." -ForegroundColor Green
} else {
    Write-Host "❌ Some checks failed. Please fix the issues before deploying." -ForegroundColor Red
    if ($missingFiles.Count -gt 0) {
        Write-Host "`nMissing files:" -ForegroundColor Red
        $missingFiles | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
    }
}

Write-Host "`n💡 Tip: Run this script after copying build files but before pushing to gh-pages`n" -ForegroundColor Cyan
