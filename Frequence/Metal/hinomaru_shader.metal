#include <metal_stdlib>
using namespace metal;

// 1. Hash function
float hash(float2 p) {
    return fract(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
}

// 2. Value noise
float vnoise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    float2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i + float2(0.0, 0.0)), hash(i + float2(1.0, 0.0)), u.x),
               mix(hash(i + float2(0.0, 1.0)), hash(i + float2(1.0, 1.0)), u.x), u.y);
}

// 3. Fractal Brownian Motion (FBM)
float fbm(float2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 5; i++) {
        v += a * vnoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}

// --- SWIFTUI FUNCTION (NO WATER, NO TEXTURE, NO VIGNETTE) ---
[[ stitchable ]] half4 hinomaru_shader(float2 position, half4 currentColor, float time, float2 size) {
    
    // Safety check
    if (size.x <= 0.001 || size.y <= 0.001) {
        return half4(0.97, 0.96, 0.93, 1.0);
    }

    // Normalize UVs
    float2 uv = position / size;
    uv = uv * 2.0 - 1.0;
    uv.x *= size.x / size.y;

    // --- COLOR PALETTE ---
    float3 paperBase = float3(0.97, 0.96, 0.93); // Solid off-white background
    float3 deepRed = float3(0.60, 0.02, 0.05);   // Darker, dried ink edge
    float3 brightRed = float3(0.85, 0.10, 0.15); // Vibrant wet center

    // --- BACKGROUND ---
    float3 finalColor = paperBase;

    // --- SUN SHAPE ---
    // Anchored perfectly in the center
    float2 sunCenter = float2(-1.1, 0.0);
    float dist = length(uv - sunCenter);

    // --- BRUSH & INK EDGES ---
    float baseDistortion = fbm(uv * 3.0 + time * 0.2) * 0.05;
    float bristleNoise = fbm(uv * 12.0 - time * 0.1) * 0.02;
    float dynamicRadius = 0.42 + baseDistortion + bristleNoise;
    
    // Splatters breaking off the edge
    float splatterNoise = fbm(uv * 50.0 + time * 1.5);
    float splatterMask = smoothstep(dynamicRadius + 0.1, dynamicRadius + 2.0 , dist) * smoothstep(0.65, 0.8, splatterNoise);
    
    // Core mask blending
    float coreMask = smoothstep(dynamicRadius + 0.02, dynamicRadius - 0.03, dist);
    float totalSunMask = max(coreMask, splatterMask * 0.8);

    // --- VELVET INK POOLING ---
    float poolNoise = fbm(uv * 6.0 + time * 0.05);
    float radialGradient = smoothstep(0.0, dynamicRadius, dist);
    float3 inkColor = mix(brightRed, deepRed, poolNoise * 0.4 + radialGradient * 0.6);
    
    // --- COMPOSITING ---
    // Blend the sun directly onto the solid background
    finalColor = mix(finalColor, inkColor, totalSunMask);

    return half4(half3(finalColor), 1.0);
}
