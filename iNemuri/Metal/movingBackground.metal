#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// The [[ rtable ]] attribute tells SwiftUI this function can be used as an effect.
// colorEffect shaders must return a half4 (RGBA) and take position and currentColor as the first arguments.
[[ stitchable ]] half4 movingBackground(float2 position, half4 currentColor, float time, float2 size) {
    
    // Normalize the pixel coordinates so they range from 0.0 to 1.0
    float2 uv = position / size;
    
    // 1. Create the math for organic, fluid movement
    // We use sine and cosine waves driven by 'time' to create flowing offsets
    float movementX = sin(uv.y * 4.0 + time * 2.0) * 0.5 + 0.5;
    float movementY = cos(uv.x * 3.0 + time * 0.5) * 0.5 + 0.5;
    
    // 2. Define the Frequence color palette (values must be between 0.0 and 1.0)
    // Dark Navy
    half3 colorTop = half3(1.0, 0.85, 0.4);
    // Deep Space Purple
    half3 colorBottom = half3(1.0, 0.5, 0.15);
    // Cyan Highlight (for the moving energy)
    half3 highlight = half3(0.1, 0.1, 0.8);
    
    // 3. Mix the base colors based on the vertical position (uv.y)
    half3 baseColor = mix(colorTop, colorBottom, uv.y);
    
    // 4. Blend in the cyan highlight using our moving math
    // Multiplying movementX and Y creates organic, blob-like intersections of light
    float highlightIntensity = movementX * movementY * 0.4;
    half3 finalColor = mix(baseColor, highlight, highlightIntensity);
    
    // Return the final color with an alpha (opacity) of 1.0
    return half4(finalColor, 1.0);
}
