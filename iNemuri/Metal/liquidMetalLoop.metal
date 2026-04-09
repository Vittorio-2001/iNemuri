#include <metal_stdlib>
using namespace metal;

// Helper function to create the twisting, overlapping "wire" distortion
float generateFluidDistortion(float2 uv, float time) {
    float2 p = uv * 3.0; // Scale of the waves
    
    // Loop to fold the space over itself, creating the complex "interwoven" look
    for (int i = 1; i < 4; i++) {
        float2 newP = p;
        // Introduce sine/cosine offsets driven by time to make it flow
        newP.x += 0.6 / float(i) * sin(float(i) * p.y + time * 0.4 + 0.3) + 0.5;
        newP.y += 0.6 / float(i) * cos(float(i) * p.x + time * 0.4 + 0.3) - 0.5;
        p = newP;
    }
    
    // Return a combined wave to create the actual thick bands
    return 0.5 * sin(3.0 * p.x) + 0.5 * cos(3.0 * p.y);
}

// Main SwiftUI Shader
[[ stitchable ]] half4 liquidMetalLoop(float2 position, half4 currentColor, float time, float2 size) {
    
    // 1. Normalize coordinates from 0.0 to 1.0, then center them (-1.0 to 1.0)
    float2 uv = position / size;
    uv = uv * 2.0 - 1.0;
    
    // Correct for aspect ratio so the circles don't stretch into ovals
    uv.x *= size.x / size.y;

    // 2. Get the complex fluid math
    float fluid = generateFluidDistortion(uv, time * 1.5);

    // 3. Define your Frequence Color Palette based on the SVG
    half3 colorCyan    = half3(0.0, 0.7, 1.0);  // Bright glowing cyan
    half3 colorMagenta = half3(0.8, 0.1, 0.9);  // Deep magenta/purple
    half3 darkBlue     = half3(0.0, 0.1, 0.3);  // Background base
    half3 deepPurple   = half3(0.15, 0.0, 0.3); // Background fade

    // 4. Create the Background Gradient (Dark Blue to Purple)
    half3 finalColor = mix(darkBlue, deepPurple, uv.y * 0.5 + 0.5);

    // 5. Shape the "Wires" and the "Glow"
    // smoothstep creates sharp, metallic-looking edges for the bands
    float wireThickness = smoothstep(0.0, 0.35, abs(fluid));
    
    // exp creates a soft, fall-off glow around the bands
    float bloomGlow = exp(-abs(fluid) * 4.0);

    // 6. Color the Wires (Flowing gradient from Cyan to Magenta)
    // The color shifts horizontally and animates over time
    float colorMixFactor = sin(uv.x * 2.0 + time) * 0.5 + 0.5;
    half3 wireColor = mix(colorCyan, colorMagenta, colorMixFactor);

    // 7. Combine everything
    // Draw the sharp wires over the background
    finalColor = mix(finalColor, wireColor, 1.0 - wireThickness);
    // Add the intense luminous bloom
    finalColor += wireColor * bloomGlow * 0.8;

    return half4(finalColor, 1.0);
}
