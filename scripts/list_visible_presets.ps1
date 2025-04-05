# PowerShell script to list all visible presets (where isHidden = false)
# from the presets.json file

# Define the path to the presets.json file
$presetsFilePath = "C:\Users\clive\VSC\BeyondHorizonCalc\assets\info\presets.json"

# Check if the file exists
if (-not (Test-Path $presetsFilePath)) {
    Write-Error "Error: Presets file not found at $presetsFilePath"
    exit 1
}

# Read and parse the JSON file
try {
    $jsonContent = Get-Content -Path $presetsFilePath -Raw | ConvertFrom-Json
    
    # Extract the presets array
    $presets = $jsonContent.presets
    
    # Filter presets where isHidden is false and select the name property
    $visiblePresets = $presets | Where-Object { -not $_.isHidden } | Select-Object -ExpandProperty name
    
    # Output header
    Write-Host "Visible Presets (isHidden = false):"
    Write-Host "=================================="
    
    # Output each preset name
    $visiblePresets | ForEach-Object { Write-Host "- $_" }
    
    # Output summary
    Write-Host ""
    Write-Host "Total visible presets: $($visiblePresets.Count)"
    Write-Host "Total presets: $($presets.Count)"
    Write-Host "Percentage visible: $([math]::Round(($visiblePresets.Count / $presets.Count) * 100, 2))%"
    
} catch {
    Write-Error "Error processing the JSON file: $_"
    exit 1
}
