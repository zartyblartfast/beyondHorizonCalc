const puppeteer = require('puppeteer');
const fs = require('fs').promises;
const path = require('path');

// Configuration
const config = {
    appUrl: 'http://localhost:3000', // Update this with your local dev server URL
    outputDir: path.join(__dirname, 'diagrams'),
    viewportSize: { width: 1200, height: 800 },
    waitTime: 2000, // Time to wait for animations/rendering in ms
};

// Get presets from your presets.json
async function getPresets() {
    const presetsPath = path.join(__dirname, '..', '..', 'assets', 'info', 'presets.json');
    const presetsContent = await fs.readFile(presetsPath, 'utf8');
    const presets = JSON.parse(presetsContent);
    return presets.presets.map(preset => ({
        id: preset.name.toLowerCase().replace(/\s+/g, '-'),
        name: preset.name
    }));
}

async function ensureOutputDir() {
    try {
        await fs.mkdir(config.outputDir, { recursive: true });
    } catch (error) {
        if (error.code !== 'EEXIST') throw error;
    }
}

async function captureDiagram(page, preset) {
    const outputPath = path.join(config.outputDir, `${preset.id}.png`);
    
    // Navigate to the preset
    const url = `${config.appUrl}/?preset=${encodeURIComponent(preset.id)}`;
    console.log(`Capturing diagram for ${preset.name} at ${url}`);
    
    await page.goto(url);
    
    // Wait for the diagram to load
    await page.waitForSelector('.diagram-container', { timeout: 10000 });
    
    // Give extra time for animations to complete
    await page.waitForTimeout(config.waitTime);
    
    // Find and screenshot the diagram
    const diagram = await page.$('.diagram-container');
    if (!diagram) {
        throw new Error(`Could not find diagram for ${preset.name}`);
    }
    
    await diagram.screenshot({
        path: outputPath,
        quality: 100
    });
    
    console.log(`Saved diagram to ${outputPath}`);
}

async function captureAllDiagrams() {
    try {
        // Ensure output directory exists
        await ensureOutputDir();
        
        // Get list of presets
        const presets = await getPresets();
        console.log(`Found ${presets.length} presets to process`);
        
        // Launch browser
        const browser = await puppeteer.launch({
            headless: "new",
            defaultViewport: config.viewportSize
        });
        
        const page = await browser.newPage();
        
        // Process each preset
        for (const preset of presets) {
            try {
                await captureDiagram(page, preset);
            } catch (error) {
                console.error(`Error capturing diagram for ${preset.name}:`, error);
            }
        }
        
        await browser.close();
        console.log('Finished capturing all diagrams');
        
    } catch (error) {
        console.error('Error in capture process:', error);
        process.exit(1);
    }
}

// Run the capture process
captureAllDiagrams();
