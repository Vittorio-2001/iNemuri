#include <metal_stdlib>
using namespace metal;

// 1. Unique helper functions to prevent linker errors
static float bioHash(float2 p) {
    return fract(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
}

static float bioNoise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    float2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(bioHash(i + float2(0.0, 0.0)), bioHash(i + float2(1.0, 0.0)), u.x),
               mix(bioHash(i + float2(0.0, 1.0)), bioHash(i + float2(1.0, 1.0)), u.x), u.y);
}

static float bioFBM(float2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * bioNoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}

// --- BIOLUMINESCENT OASIS SHADER ---
[[ stitchable ]] half4 bioluminescent_moon(float2 position, half4 currentColor, float time, float2 size) {
    
    // Safety check
    if (size.x <= 0.001 || size.y <= 0.001) {
        return half4(0.02, 0.05, 0.12, 1.0);
    }

    // Normalize UVs
    float2 uv = position / size;
    uv = -(uv * 1.5 - 1.0);
    uv.x *= size.x / size.y;

    // --- COLOR PALETTE ---
    float3 deepOcean = float3(0.02, 0.05, 0.12); // Very dark navy
    float3 cyanGlow = float3(0.10, 0.85, 0.95);  // Electric neon blue
    float3 brightCore = float3(0.85, 0.95, 1.0); // Almost white for the center

    float3 finalColor = deepOcean;

    // --- ORB / MOON ---
    float sunY = 0; // Fixed slightly higher up
    float2 sunCenter = float2(-0.7, sunY);                                           // IMPORTANT!!!
    float dist = length(uv - sunCenter);

    // Subtle pulsing radius
    float glowPulse = sin(time * 1.2) * 0.015;
    float radius = 0.35 + glowPulse;
    
    // Solid core and outer soft glow
    float coreMask = smoothstep(radius + 0.01, radius - 0.01, dist);
    // Inverse distance creates a beautiful, soft optical glow
    float outerGlow = 0.015 / (abs(dist - radius) + 0.02);

    // --- WATER REFLECTION ---
    float waterLine = -0.15;
    float isWater = step(uv.y, waterLine);
    float2 waterUv = uv;

    // Create chaotic, glowing wave ripples using FBM
    float waveNoise = bioFBM(waterUv * 10.0 + float2(time * 0.5, 0.0));
    // Warp the X coordinates based on the noise and sine waves
    waterUv.x += sin(waterUv.y * 35.0 + time * 2.5) * 0.04 * waveNoise;

    // Calculate mirrored reflection
    float refDist = length(waterUv - float2(-0.7, -sunY + waterLine * 2.0));
    float refMask = smoothstep(radius + 0.05, radius - 0.05, refDist);

    // Highlight the crests of the water just below the horizon line
    float surfaceGlow = smoothstep(waterLine, waterLine - 0.03, waterUv.y) * smoothstep(waterLine - 0.15, waterLine, waterUv.y);

    // --- COMPOSITING ---
    
    // 1. Build the water (dark base + reflection + glowing wave crests)
    float3 reflectionColor = mix(deepOcean, cyanGlow, refMask * 0.4 + waveNoise * 0.2);
    reflectionColor += cyanGlow * surfaceGlow * waveNoise * 1.5; // Add bright crests
    finalColor = mix(finalColor, reflectionColor, isWater);

    // 2. Build the Moon (Glow + Core)
    float3 moonColor = mix(cyanGlow * outerGlow, brightCore, coreMask);
    // Add moon only above the water line
    finalColor = mix(finalColor, moonColor, max(coreMask, outerGlow * 0.5) * (1.0 - isWater));

    return half4(half3(finalColor), 1.0);
}
