#include <metal_stdlib>
using namespace metal;

// 1. Uniquely named hash function
float zenHash(float2 p) {
    return fract(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
}

// 2. Uniquely named noise function
float zenNoise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    float2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(zenHash(i + float2(0.0, 0.0)), zenHash(i + float2(1.0, 0.0)), u.x),
               mix(zenHash(i + float2(0.0, 1.0)), zenHash(i + float2(1.0, 1.0)), u.x), u.y);
}

// 3. Uniquely named FBM function
float zenFBM(float2 p) {
    float v = 0.5;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * zenNoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}

// --- COMPLEX MEDITATION SHADER ---
[[ stitchable ]] half4 zen_mandala(float2 position, half4 currentColor, float time, float2 size) {
    
    // Safety check
    if (size.x <= 0.001 || size.y <= 0.001) {
        return half4(0.02, 0.05, 0.1, 1.0);
    }

    // Normalize UVs and fix aspect ratio
    float2 uv = position / size;
    uv = uv * - 1.0;
    uv.x *= size.x / size.y;

    // Convert to Polar Coordinates for circular geometry
    float r = length(uv) ;                 // Radius (distance from center)
    float a = atan2(uv.y, uv.x);          // Angle

    // --- MEDITATIVE KINEMATICS ---
    // A slow, smooth sine wave that acts as a breathing guide.
    // Maps from 0.0 (exhale) to 1.0 (inhale)
    float breath = (sin(time * 0.6) + 1.0) * 0.5;

    // --- 1. DEEP BACKGROUND ---
    // A calming gradient from dark indigo in the center to deep void at the edges
    float3 finalColor = mix(float3(0.04, 0.08, 0.15), float3(0.01, 0.02, 0.05), r);

    // --- 2. ETHEREAL SMOKE (Incense) ---
    // Slowly drifting ambient noise using the newly named zenFBM
    float smoke = zenFBM(uv * 2.5 + float2(time * 0.04, -time * 0.06));
    float3 smokeColor = float3(0.3, 0.2, 0.5) * smoke * 0.25;
    finalColor += smokeColor;

    // --- 3. ZEN RIPPLES ---
    // Concentric rings moving outward
    float rippleFreq = 25.0;
    float rippleSpeed = -1.2; // Negative moves outward
    float ripples = sin(r * rippleFreq + time * rippleSpeed);
    ripples = smoothstep(0.9, 1.0, ripples); // Isolate the sharp peaks of the waves
    
    // Fade ripples out near the very center and the edges
    float rippleMask = smoothstep(0.1, 0.3, r) * smoothstep(1.2, 0.5, r);
    float3 rippleColor = float3(0.2, 0.5, 0.7) * ripples * rippleMask * 0.4;
    finalColor += rippleColor;

    // --- 4. SACRED GEOMETRY (Lotus Petals) ---
    float symmetry = 12.0; // 12 intersecting points
    float petalAngle = a + time * 0.1; // Slowly rotates the entire structure
    
    // Create overlapping petal shapes using the absolute cosine of the angle
    float petalShape = abs(cos(petalAngle * (symmetry / 2.0)));
    
    // Map the shape to the radius, expanding and contracting with the breath
    float petalDist = abs(r - 0.4 - petalShape * 0.15 * breath);
    
    // Create an intense, soft-falloff glow using inverse distance
    float petalGlow = 0.008 / (petalDist + 0.01);
    float3 petalColor = float3(0.3, 0.7, 0.9) * petalGlow; // Cyan/Blue glow
    finalColor += petalColor;

    // --- 5. THE BREATHING CORE (Focal Point) ---
    // Expands as you inhale, shrinks as you exhale
    float orbRadius = 0.10 + breath * 0.06;
    float orbDist = abs(r - orbRadius);
    
    // Inner solid core + outer soft glow
    float coreMask = smoothstep(orbRadius, orbRadius - 0.02, r);
    float orbGlow = 0.015 / (orbDist + 0.01);
    
    float3 warmGold = float3(1.0, 0.8, 0.4);
    finalColor += warmGold * orbGlow;
    finalColor = mix(finalColor, warmGold, coreMask * 0.8);

    // --- 6. VIGNETTE ---
    // Darken the edges for extreme focus
    float vignette = smoothstep(1.5, 0.5, r);
    finalColor *= vignette;

    return half4(half3(finalColor), 1.0);
}
