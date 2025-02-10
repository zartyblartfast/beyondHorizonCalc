# Image Display Implementation Issues - Lessons Learned

## Requirements

### General Requirements
1. Data Structure:
   - Images stored in preset details as imageURL_1 through imageURL_4
   - Optional source attribution in imageURL_1_source through imageURL_4_source
   - All image URLs must be valid and accessible

2. Error Handling:
   - Graceful handling of missing images
   - Fallback for failed image loads
   - No layout disruption when images are missing

### 1. Preset 'i' Icon Popup Requirements
1. Layout:
   - 2x2 grid arrangement for up to 4 images
   - Consistent 120x90px container size for each image
   - 8px gap between grid items
   - Maximum grid width of 400px
   - Centered grid within popup

2. Image Display:
   - Original aspect ratio preserved
   - No image distortion
   - Images centered within containers
   - Light background (e.g., #f5f5f5) to define boundaries
   - Padding inside containers to prevent image touch edges

3. Functionality:
   - Lazy loading enabled
   - Click to open full-size image in new tab
   - Subtle hover effect (e.g., opacity change)
   - Source attribution displayed below each image if available
   - Tooltip showing source on hover

### 2. Long Line of Sight Report Requirements
1. Layout:
   - 2x2 grid arrangement for up to 4 images
   - Consistent 360x270px container size for each image
   - 16px gap between grid items
   - Maximum grid width of 800px
   - Proper spacing before and after grid (16px margin)

2. Image Display:
   - Original aspect ratio preserved
   - No image distortion
   - Images centered within containers
   - Light background (e.g., #f5f5f5) to define boundaries
   - Padding inside containers (8px)

3. Integration:
   - Clean integration with surrounding report text
   - No layout shifts during image loading
   - Consistent spacing with other report sections
   - Source attribution clearly visible below each image
   - Lazy loading for performance

### Performance Requirements
1. Loading:
   - Lazy loading for all images
   - Proper loading indicators
   - No layout shifts during loading
   - Efficient memory usage

2. Responsiveness:
   - Quick popup display
   - Smooth scrolling in report
   - No freezing during image loading
   - Proper cleanup when popup closes

## Context
Attempted to enhance the Beyond Horizon Calculator app to:
1. Add image support to the preset 'i' icon popup content
2. Add image support to the Long Line of Sight report
3. Maintain aspect ratios and implement 2x2 grid layouts

## Issues Encountered

### 1. Preset 'i' Icon Popup Issues
- Content disappeared completely, showing only grey space
- Likely caused by:
  - Incorrect HTML structure nesting
  - CSS conflicts with the dialog container
  - Improper access to nested preset data structure
  - Over-complicated CSS grid implementation

### 2. Report Image Display Issues
- Images failed to display in the report
- Problems included:
  - Inconsistent access to image URLs in the preset data
  - Overly complex grid layout implementation
  - Aspect ratio handling complications
  - Large gaps between presets

### 3. Implementation Missteps
1. Tried to implement too many changes at once:
   - Grid layout
   - Aspect ratio handling
   - Image caching
   - CSS styling
   
2. Lost track of working state:
   - No incremental testing
   - Multiple overlapping changes
   - No clear rollback points

3. Overcomplicated solutions:
   - Added unnecessary wrapper divs
   - Complex CSS grid implementations
   - Mixing inline and stylesheet styles

## Failed Implementation Attempts

### Attempt 1: Initial Image Cache Service
```dart
class PresetImageCache {
  static final Map<String, Uint8List> _imageCache = {};
  
  static Future<Uint8List?> getImage(String url) async {
    if (_imageCache.containsKey(url)) {
      return _imageCache[url];
    }
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        _imageCache[url] = response.bodyBytes;
        return response.bodyBytes;
      }
    } catch (e) {
      print('Error loading image: $e');
    }
    return null;
  }
}
```
**Issue**: Service was created but never properly integrated with image loading. Added unnecessary complexity without benefit.

### Attempt 2: Report Image Display (First Try)
```dart
content.writeln('''
  <div class="image-container">
    <img src="$imageUrl" 
         class="report-img" 
         loading="lazy"
         width="360" height="270" />
    ${source != null ? '<div class="image-source">Source: $source</div>' : ''}
  </div>
''');
```
**Issues**:
- Fixed dimensions caused image distortion
- No aspect ratio preservation
- Images failed to load due to incorrect data access path

### Attempt 3: Report Grid Layout
```css
.preset-images {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
  margin: 16px 0;
  max-width: 800px;
}
.image-container {
  display: flex;
  flex-direction: column;
  align-items: center;
}
.report-img-wrapper {
  width: 360px;
  height: 270px;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #f5f5f5;
  border-radius: 4px;
  padding: 8px;
}
```
**Issues**:
- Over-engineered solution with unnecessary wrapper divs
- Grid layout broke existing content flow
- Large gaps appeared between presets

### Attempt 4: Popup Thumbnail Grid (Failed)
```dart
content.writeln('''
  <div class="thumbnail">
    <div class="thumbnail-wrapper">
      <img src="$imageUrl" 
           class="thumbnail-img" 
           loading="lazy"
           onclick="window.open('$imageUrl', '_blank')"
           title="${source ?? ''}" />
    </div>
  </div>
''');

// CSS
content.writeln('''
  <style>
    .preset-thumbnails {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 8px;
      margin: 8px 0;
      max-width: 400px;
    }
    .thumbnail-wrapper {
      width: 120px;
      height: 90px;
      display: flex;
      align-items: center;
      justify-content: center;
      background-color: #f5f5f5;
    }
  </style>
''');
```
**Issues**:
- Content disappeared completely
- CSS grid conflicted with dialog container
- Incorrect nesting of HTML elements
- Over-complicated structure for simple thumbnail display

### Attempt 5: Data Access Issues
```dart
// Original working code
final details = preset['details'];
final imageUrl = details['imageURL_$i'];

// Failed attempt
final imageUrl = preset['details']['imageURL_$i'];
```
**Issues**:
- Direct nested access caused null pointer issues
- Lost track of proper data structure navigation
- Inconsistent access patterns between report and popup

## Analysis of Current Code Structure

### 1. Content Generation Pattern
The existing code in PresetInfoService follows a clear pattern:
1. Loads JSON data from presets.json
2. Creates a StringBuffer for HTML generation
3. Builds content systematically:
   - Writes header/introduction
   - Iterates through presets
   - Generates HTML in a predictable structure
4. Uses simple, reliable HTML patterns:
   - Clear element hierarchy
   - Minimal nesting
   - Direct string interpolation
   - Consistent class naming

### 2. HTML Structure
Current HTML generation follows these patterns:
```html
<!-- Popup Content Structure -->
<ul>
  <li>
    <strong>Preset Name</strong>
    <p class="preset-details">
      [Measurement details]
      [Location details]
      [Conditions and notes]
    </p>
  </li>
</ul>

<!-- Report Content Structure -->
<div class="section">
  <h3>Notable Cases</h3>
  <ul>
    <li>
      <h4>Preset Name</h4>
      <div class="measurements">
        [Measurement details]
      </div>
      <div class="location-details">
        [Location information]
      </div>
    </li>
  </ul>
</div>
```

## Analysis of Failed Attempts

### 1. Root Causes of Failures
1. **Insufficient Code Analysis**:
   - Failed to understand existing HTML generation patterns
   - Didn't analyze how content integrates with Flutter WebView
   - Overlooked existing CSS patterns and class usage

2. **Requirements Issues**:
   - Started coding before fully defining requirements
   - No clear acceptance criteria
   - Mixed layout and functionality concerns

3. **Over-engineering**:
   - Added unnecessary complexity (image cache service)
   - Created overly complex CSS grid structures
   - Added wrapper divs without clear purpose

4. **Poor Implementation Strategy**:
   - Attempted too many changes at once
   - No incremental testing
   - No clear rollback points

### 2. Specific Implementation Mistakes

1. **HTML Structure Issues**:
   ```html
   <!-- Bad: Complex nesting -->
   <div class="thumbnail">
     <div class="thumbnail-wrapper">
       <div class="image-container">
         <img .../>
       </div>
     </div>
   </div>

   <!-- Better: Simple, flat structure -->
   <div class="image-container">
     <img .../>
     <div class="source">...</div>
   </div>
   ```

2. **CSS Problems**:
   - Mixed inline and stylesheet styles
   - Over-complicated grid implementation
   - Unnecessary wrapper elements
   - Conflicting style rules

3. **Data Access Issues**:
   - Inconsistent preset data access patterns
   - No error handling for missing data
   - Direct nested property access without checks

4. **Integration Problems**:
   - Failed to maintain existing HTML structure
   - Broke popup layout with complex grids
   - Created layout shifts during loading

### 3. The "Going in Circles" Trap
1. **Symptoms**:
   - Multiple attempts with similar mistakes
   - Lost track of working state
   - Each fix created new problems
   - No clear progress direction

2. **Causes**:
   - No systematic approach
   - Reactive instead of planned changes
   - Missing root cause analysis
   - No clear success criteria

## Proposed Design Approach

### 1. Design Principles
1. **Maintain Existing Patterns**:
   - Follow current HTML generation structure
   - Use consistent data access patterns
   - Keep CSS organization simple

2. **Incremental Implementation**:
   - Start with basic image display
   - Add grid layout separately
   - Test each feature independently
   - Clear rollback points

3. **Clean Integration**:
   - Respect existing HTML hierarchy
   - Consistent class naming
   - Simple, maintainable CSS
   - Clear separation of concerns

4. **Error Handling**:
   - Graceful fallbacks
   - Proper data validation
   - Loading state management
   - Clear error messages

## Code Structure Problems

### 1. HTML Generation
```dart
// Problematic nested string interpolation
content.writeln('''
  ${hasImages ? '<div class="preset-images">' : ''}
  ${imageHtml.toString()}
  ${hasImages ? '</div>' : ''}
''');
```
**Issues**:
- Complex string interpolation made debugging difficult
- HTML structure became unclear
- Difficult to maintain proper element nesting

### 2. CSS Management
```dart
// Mixed inline and stylesheet styles
content.writeln('<div style="margin: 8px 0;">');
content.writeln('''
  <style>
    .preset-images { margin: 16px 0; }
  </style>
''');
```
**Issues**:
- Inconsistent styling approach
- Style conflicts
- Difficult to debug layout issues

### 3. Image URL Handling
```dart
// Inconsistent URL access
imageUrl = details['imageURL_$i'];  // Some places
imageUrl = preset['details']['imageURL_$i'];  // Other places
```
**Issues**:
- Inconsistent data access patterns
- No error handling for missing data
- No validation of URL format

## Working Code That Was Lost

### Original Working Popup Content
```dart
content.writeln('<li><strong>${preset['name']}</strong>');
content.writeln('<p class="preset-details">');
// Simple, direct content generation without complex nesting
```

### Original Working Report Layout
```dart
content.writeln('<div class="measurements">');
content.writeln('<p><strong>Key Measurements:</strong></p>');
// Clear, straightforward HTML structure
```

## Recommendations for Future Implementation

### 1. Start with Basic Structure
```dart
// Simple image display first
content.writeln('<div class="image">');
content.writeln('<img src="$imageUrl" alt="Preset image" />');
content.writeln('</div>');
```

### 2. Add Styling Incrementally
```css
/* Step 1: Basic image containment */
.image img {
  max-width: 100%;
  height: auto;
}

/* Step 2: Add grid layout */
.image-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
}
```

### 3. Proper Data Access
```dart
// Safe data access pattern
final details = preset['details'];
if (details != null) {
  final imageUrl = details['imageURL_$i'];
  if (imageUrl != null) {
    // Process image
  }
}
```

### 4. Testing Strategy
1. Create test data with various image counts
2. Test each layout change independently
3. Verify data access patterns
4. Document working states for rollback points

## Recovery Plan

### 1. Restore Working State
1. Revert to last known working version of `preset_info_service.dart`
2. Document the working state thoroughly
3. Create a new branch for future attempts

### 2. Incremental Implementation
1. First milestone: Basic image display in both views
2. Second milestone: Aspect ratio preservation
3. Third milestone: Grid layout implementation
4. Final milestone: Polish and optimization

### 3. Testing Requirements
1. Create test presets with:
   - No images
   - Single image
   - Multiple images (2-4)
   - Various aspect ratios
2. Test in different window sizes
3. Verify loading performance
4. Check memory usage

### 4. Documentation Updates
1. Document successful approaches
2. Maintain list of failed attempts
3. Create debugging guide
4. Update implementation guide

## Original Requirements Not Met
1. 2x2 grid layout for images
2. Aspect ratio preservation
3. Consistent spacing between presets
4. Thumbnail support in popup
5. Full-size images in report

## Next Steps
Consider a fresh implementation focusing on:
1. Basic image display first
2. Simple, proven layout techniques
3. Incremental feature addition
4. Regular testing at each step

## Analysis of Data and Display Issues

### 1. Presets.json Structure Analysis
```json
{
  "presets": [
    {
      "name": "Pic de Finstrelles to Pic Gaspard",
      "details": {
        "imageURL_1": "https://raw.githubusercontent.com/...",
        "imageURL_1_source": "https://beyondrange.wordpress.com/...",
        "imageURL_2": "https://raw.githubusercontent.com/...",
        "imageURL_2_source": "https://beyondrange.wordpress.com/...",
        "imageURL_3": "https://raw.githubusercontent.com/...",
        "imageURL_3_source": null,
        "imageURL_4": "https://raw.githubusercontent.com/...",
        "imageURL_4_source": null
      }
    }
  ]
}
```

Key Observations:
1. Image Structure:
   - Images are stored in sequential keys (imageURL_1 through imageURL_4)
   - Sources may be null for some images
   - All images are hosted on GitHub raw content
   - URLs are complete and absolute

2. Data Access Pattern:
   - Requires nested access: preset['details']['imageURL_1']
   - Previous implementation used inconsistent access patterns
   - No validation of URL existence or format

### 2. Report Display Issues

1. **First Preset Spacing Problem**:
   ```html
   <!-- Current Structure -->
   <li>
     <h4>Preset Name</h4>
     <div class="measurements">...</div>
     <!-- No height constraint -->
     <div class="preset-images">...</div>
     <!-- No margin control -->
   </li>
   <hr>
   ```
   Issues:
   - No explicit height control on image container
   - Missing margin constraints between sections
   - HR tag creating excessive spacing
   - No clear vertical rhythm in layout

2. **Missing Images Root Causes**:
   - Direct URL access without error handling
   - No placeholder for missing images
   - No loading state indication
   - No fallback content
   - Images attempted to load before container ready

3. **Layout Flow Problems**:
   ```html
   <!-- Problematic Layout -->
   <div class="section">
     <ul>
       <li>
         [Content]
         <!-- Images floating outside normal flow -->
         <div class="preset-images">...</div>
         [More Content]
       </li>
     </ul>
   </div>
   ```
   Issues:
   - Images breaking document flow
   - Inconsistent margins and padding
   - No clear containment strategy
   - Mixed positioning contexts

### 3. CSS Issues Contributing to Problems

1. **Missing Containment**:
```css
.preset-images {
  /* Missing */
  display: grid;
  /* No height constraint */
  /* No overflow handling */
}
```

2. **Inconsistent Spacing**:
```css
/* Current */
li {
  margin-bottom: 16px;
}
hr {
  margin: 24px 0;
}
/* Results in 40px gap */
```

3. **Missing Loading States**:
```css
/* Missing */
.image-loading {
  min-height: 100px;
  background: #f5f5f5;
}
```

### 4. Implementation Recommendations

1. **Proper Data Access**:
```dart
// Safe image URL retrieval
String? getImageUrl(Map<String, dynamic> details, int index) {
  return details['imageURL_$index'] as String?;
}

// Safe source retrieval
String? getImageSource(Map<String, dynamic> details, int index) {
  return details['imageURL_${index}_source'] as String?;
}
```

2. **Controlled Layout Structure**:
```html
<div class="preset-case">
  <div class="preset-content">
    <h4>...</h4>
    <div class="measurements">...</div>
  </div>
  <div class="preset-images">
    <!-- Fixed height container -->
    <!-- Controlled grid layout -->
  </div>
  <div class="preset-footer">...</div>
</div>
```

3. **Proper CSS Containment**:
```css
.preset-case {
  margin-bottom: 2rem;
  /* Clear containment */
}

.preset-images {
  height: auto;
  min-height: 270px;
  margin: 1rem 0;
  /* Prevent layout shifts */
}
```

These analyses reveal that the previous implementation failed to:
1. Properly understand and handle the data structure
2. Implement proper containment and spacing
3. Handle loading states and errors
4. Maintain consistent layout flow

## Analysis of 'i' Icon Popup Grey Space Issues

1. **Container Creation Before Content**:
   ```html
   <!-- Problematic Implementation -->
   <div class="thumbnail-wrapper">
     <div class="image-container">
       <!-- Fixed size container created regardless of image status -->
       width: 120px;
       height: 90px;
       background-color: #f5f5f5;
       <!-- Container exists even if image fails to load -->
     </div>
   </div>
   ```
   Problem:
   - Container with background color was created before verifying image existence
   - Fixed dimensions were applied regardless of content
   - No collapse mechanism when empty

2. **CSS Grid Layout Issues**:
   ```css
   .preset-thumbnails {
     display: grid;
     grid-template-columns: repeat(2, 1fr);
     gap: 8px;
     /* No handling of empty grid cells */
     /* Grid created even with no images */
   }
   ```
   Problem:
   - Grid structure maintained even without content
   - Empty cells still took up space
   - No conditional rendering based on image count

3. **Error in Data Access Pattern**:
   ```dart
   // Problematic Implementation
   final imageUrl = details['imageURL_$i'];
   if (imageUrl != null) {
     // Container created before URL validation
     content.writeln('<div class="thumbnail-wrapper">');
     // Attempt to load image
     content.writeln('<img src="$imageUrl" .../>');
   }
   // Container closed regardless of image status
   content.writeln('</div>');
   ```
   Problem:
   - HTML structure generated before validating data
   - Containers created even when images failed to load
   - No cleanup of empty containers

4. **Missing Content Validation**:
   ```dart
   // No check for actual content before creating structure
   content.writeln('<div class="preset-thumbnails">');
   for (int i = 1; i <= 4; i++) {
     // Grid containers created regardless of total images
   }
   content.writeln('</div>');
   ```
   Problem:
   - No validation of total available images
   - Grid structure created without checking content
   - Empty containers maintained in DOM

5. **Incorrect Error Handling**:
   ```html
   <!-- Generated even for missing images -->
   <div class="image-container">
     <!-- No fallback content -->
     <!-- No error state handling -->
     <!-- Background color always visible -->
   </div>
   ```
   Problem:
   - No proper error states
   - Background color shown for errors
   - Missing fallback content

### Correct Approach Should Be:

1. **Validate Content First**:
   ```dart
   bool hasImages = false;
   List<String> validImageUrls = [];
   
   // Collect valid images first
   for (int i = 1; i <= 4; i++) {
     final imageUrl = details['imageURL_$i'];
     if (imageUrl != null && imageUrl.isNotEmpty) {
       validImageUrls.add(imageUrl);
       hasImages = true;
     }
   }
   
   // Only create structure if we have images
   if (hasImages) {
     // Generate grid
   }
   ```

2. **Proper Container Management**:
   ```html
   <!-- Only create container for valid images -->
   ${validImages.map((img, index) => `
     <div class="image-cell">
       <div class="image-wrapper">
         <img class="preset-image"
              src="${img.url}"
              alt="Image ${index + 1}"
              loading="lazy"
              onload="this.style.opacity='1'"
              onerror="this.style.display='none'" />
       </div>
       ${img.source ? `
         <div class="image-source">${img.source}</div>
       ` : ''}
     </div>
   `).join('')}
   ```

3. **Proper CSS Structure**:
   ```css
   /* Grid System */
   .image-grid {
     --grid-gap: var(--is-popup, 8px, 16px);
     --max-width: var(--is-popup, 400px, 800px);
     
     display: grid;
     grid-template-columns: repeat(2, 1fr);
     gap: var(--grid-gap);
     width: 100%;
     max-width: var(--max-width);
     margin: 1rem 0;
   }

   /* Cell Container */
   .image-cell {
     --cell-padding: var(--is-popup, 4px, 8px);
     
     aspect-ratio: 4/3;
     background: #f5f5f5;
     border-radius: 4px;
     padding: var(--cell-padding);
     position: relative;
   }

   /* Image Wrapper */
   .image-wrapper {
     width: 100%;
     height: 100%;
     display: flex;
     align-items: center;
     justify-content: center;
     overflow: hidden;
   }

   /* Image */
   .preset-image {
     max-width: 100%;
     max-height: 100%;
     width: auto;
     height: auto;
     object-fit: contain;
     opacity: 0;
     transition: opacity 0.2s;
   }

   /* Source Attribution */
   .image-source {
     position: absolute;
     bottom: 0;
     left: 0;
     right: 0;
     font-size: 0.8em;
     text-align: center;
     padding: 4px;
     background: rgba(255,255,255,0.9);
   }
   ```

### 4. Key Aspects

1. **Aspect Ratio Preservation**:
   - Uses `object-fit: contain` to maintain image proportions
   - Container has fixed aspect ratio (4:3)
   - Images scale within boundaries while keeping proportions
   - No distortion regardless of original image dimensions

2. **Responsive Behavior**:
   - Grid cells maintain equal size
   - Images center within cells
   - Source text stays at bottom
   - Smooth loading transition

3. **Error Prevention**:
   - Images fade in when loaded
   - Hidden when error occurs
   - Background visible only with content
   - Clean fallback states

4. **Performance**:
   - Lazy loading for all images
   - No layout shifts during load
   - Efficient DOM structure
   - Minimal style calculations

This strategy ensures:
1. Consistent layout in both popup and report
2. Original image proportions are maintained
3. Clean handling of different image sizes
4. Proper spacing and alignment
5. Efficient loading and error states

Would you like me to elaborate on any of these aspects or add more specific details to any section?

## 2x2 Grid Implementation Strategy

### 1. Grid Container Design

1. **Basic Grid Structure**:
   ```css
   /* Common grid structure for both popup and report */
   .image-grid {
     display: grid;
     grid-template-columns: repeat(2, 1fr);  /* Creates 2 equal columns */
     gap: var(--grid-gap);                   /* 8px for popup, 16px for report */
     width: 100%;
     max-width: var(--max-width);            /* 400px popup, 800px report */
   }
   ```

2. **Individual Cell Design**:
   ```css
   .image-cell {
     aspect-ratio: 4/3;                      /* Maintains consistent cell shape */
     background: #f5f5f5;
     display: flex;
     align-items: center;
     justify-content: center;
     padding: var(--cell-padding);           /* 4px popup, 8px report */
     position: relative;                      /* For absolute positioning of source */
   }
   ```

### 2. Image Aspect Ratio Preservation

1. **Image Container Strategy**:
   ```css
   .image-wrapper {
     width: 100%;
     height: 100%;
     display: flex;
     align-items: center;
     justify-content: center;
     overflow: hidden;                        /* Prevents image overflow */
   }

   .preset-image {
     max-width: 100%;
     max-height: 100%;
     width: auto;                            /* Allow natural scaling */
     height: auto;                           /* Allow natural scaling */
     object-fit: contain;                    /* Key to preserving aspect ratio */
   }
   ```

2. **Sizing Strategy**:
   ```html
   <!-- Popup dimensions -->
   <div class="image-cell" style="--cell-size: 120px;">
     <!-- Results in 120x90px container -->
   </div>

   <!-- Report dimensions -->
   <div class="image-cell" style="--cell-size: 360px;">
     <!-- Results in 360x270px container -->
   </div>
   ```

### 3. Implementation Approach

1. **HTML Structure**:
   ```html
   <div class="image-grid">
     <!-- Only created for valid images -->
     ${validImages.map((img, index) => `
       <div class="image-cell">
         <div class="image-wrapper">
           <img class="preset-image"
                src="${img.url}"
                alt="Image ${index + 1}"
                loading="lazy"
                onload="this.style.opacity='1'"
                onerror="this.style.display='none'" />
         </div>
         ${img.source ? `
           <div class="image-source">${img.source}</div>
         ` : ''}
       </div>
     `).join('')}
   </div>
   ```

2. **Complete CSS Structure**:
   ```css
   /* Grid System */
   .image-grid {
     --grid-gap: var(--is-popup, 8px, 16px);
     --max-width: var(--is-popup, 400px, 800px);
     
     display: grid;
     grid-template-columns: repeat(2, 1fr);
     gap: var(--grid-gap);
     width: 100%;
     max-width: var(--max-width);
     margin: 1rem 0;
   }

   /* Cell Container */
   .image-cell {
     --cell-padding: var(--is-popup, 4px, 8px);
     
     aspect-ratio: 4/3;
     background: #f5f5f5;
     border-radius: 4px;
     padding: var(--cell-padding);
     position: relative;
   }

   /* Image Wrapper */
   .image-wrapper {
     width: 100%;
     height: 100%;
     display: flex;
     align-items: center;
     justify-content: center;
     overflow: hidden;
   }

   /* Image */
   .preset-image {
     max-width: 100%;
     max-height: 100%;
     width: auto;
     height: auto;
     object-fit: contain;
     opacity: 0;
     transition: opacity 0.2s;
   }

   /* Source Attribution */
   .image-source {
     position: absolute;
     bottom: 0;
     left: 0;
     right: 0;
     font-size: 0.8em;
     text-align: center;
     padding: 4px;
     background: rgba(255,255,255,0.9);
   }
   ```

### 4. Key Aspects

1. **Aspect Ratio Preservation**:
   - Uses `object-fit: contain` to maintain image proportions
   - Container has fixed aspect ratio (4:3)
   - Images scale within boundaries while keeping proportions
   - No distortion regardless of original image dimensions

2. **Responsive Behavior**:
   - Grid cells maintain equal size
   - Images center within cells
   - Source text stays at bottom
   - Smooth loading transition

3. **Error Prevention**:
   - Images fade in when loaded
   - Hidden when error occurs
   - Background visible only with content
   - Clean fallback states

4. **Performance**:
   - Lazy loading for all images
   - No layout shifts during load
   - Efficient DOM structure
   - Minimal style calculations

This strategy ensures:
1. Consistent layout in both popup and report
2. Original image proportions are maintained
3. Clean handling of different image sizes
4. Proper spacing and alignment
5. Efficient loading and error states

Would you like me to elaborate on any of these aspects or add more specific details to any section?
