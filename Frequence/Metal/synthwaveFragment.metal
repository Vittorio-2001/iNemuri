#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

float synthwaveHash(float2 p) {
    float3 p3  = fract(float3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// The signature now perfectly matches your Swift code's inputs!
[[ stitchable ]] half4 synthwaveFragment(float2 position, half4 currentColor, float time, float2 size) {
    
    // Calculate coordinates (-1.0 to 1.0) using the size passed from Swift
    float2 uv = (position / size) * 2.0 - 1.18;
    uv.y = -uv.y ;
    
    float3 finalColor = float3(0.0, 0.0, 0.0);
    
    // --- THE STARS ---
    if (uv.y > 0.0) {
        float randValue = synthwaveHash(uv);
        if (randValue > 0.998) {
            float3 starColor = mix(float3(0.0, 1.0, 1.0), float3(1.0, 1.0, 0.0), synthwaveHash(uv + 1.0));
            
            // Optional bonus: Make the stars twinkle using the time variable!
            starColor *= (sin(time * 3.0 + randValue * 100.0) * 0.5 + 0.5);
            
            finalColor += starColor;
        }
    }
    
    // --- THE HORIZON GLOW ---
    float glowIntensity = 0.008 / (abs(uv.y) + 0.001);
    float3 neonBlue = float3(0.0, 0.6, 1.0);
    finalColor += neonBlue * glowIntensity;
    
    // --- THE RETRO GRID ---
    if (uv.y < 0.0) {
        float depth = 1.0 / (abs(uv.y) + 0.001);
        
        // ANIMATION MAGIC: We subtract 'time' from the depth coordinate.
        // This makes the horizontal lines constantly rush toward the camera!
        float speed = -0.5; // Change this to make it move faster or slower
        float2 gridUV = float2(uv.x * depth, depth - (time * speed));
        
        gridUV *= 6.0;
        
        float2 grid = fract(gridUV);
        float lineThickness = 0.03;
        
        float2 lines = smoothstep(lineThickness, 0.0, grid) + smoothstep(1.0 - lineThickness, 1.0, grid);
        float gridAlpha = max(lines.x, lines.y);
        
        float depthFade = exp(-depth * 0.15);
        float3 neonGreen = float3(1.0, 0.0, 0.8);
        
        finalColor += neonGreen * gridAlpha * depthFade;
    }
    
    return half4(half3(finalColor), 1.0);
}
