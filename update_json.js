const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, 'assets', 'info', 'presets_bigList.json');
const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));

// Add isHidden flag to each preset
data.forEach(preset => {
    preset.isHidden = true;
});

// Write back to file with proper formatting
fs.writeFileSync(filePath, JSON.stringify(data, null, 4), 'utf8');
