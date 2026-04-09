import SwiftUI

struct AlarmCard: View {
    @Binding var alarm: AlarmItem
    
    // We need a start date to calculate the continuous animation time
    let startDate = Date()
    
    var body: some View {
        // 1. GeometryReader gives us the exact 'size' of the card
        GeometryReader { geometry in
            
            // 2. TimelineView gives us the continuous 'time' updates
            TimelineView(.animation) { context in
                
                // Calculate how many seconds have passed for the shader math
                let elapsedTime = context.date.timeIntervalSince(startDate)
                
                ZStack(alignment: .center) {
                    
                    // --- THE DYNAMIC METAL BACKGROUND ---
                    Group {
                        if alarm.shaderName == "liquidMetalLoop" {
                            Rectangle()
                                .fill(.black) // Base color needed for shader to render
                                .colorEffect(ShaderLibrary.liquidMetalLoop(.float(elapsedTime), .float2(geometry.size)))
                        } else if alarm.shaderName == "hinomaru_shader" {
                            Rectangle()
                                .fill(.black)
                                .colorEffect(ShaderLibrary.hinomaru_shader(.float(elapsedTime), .float2(geometry.size)))
                        } else if alarm.shaderName == "zen_mandala" {
                            Rectangle()
                                .fill(.black)
                                .colorEffect(ShaderLibrary.zen_mandala(.float(elapsedTime), .float2(geometry.size)))
                        } else if alarm.shaderName == "bioluminescent_moon" {
                            Rectangle()
                                .fill(.black)
                                .colorEffect(ShaderLibrary.bioluminescent_moon(.float(elapsedTime), .float2(geometry.size)))
                        } else if alarm.shaderName == "synthwaveFragment" {
                            Rectangle()
                                .fill(.black)
                                .colorEffect(ShaderLibrary.synthwaveFragment(.float(elapsedTime), .float2(geometry.size)))
                        } else {
                            // Fallback to your default design
                            Rectangle()
                                .fill(.black)
                                .colorEffect(ShaderLibrary.movingBackground(.float(elapsedTime), .float2(geometry.size)))
                        }
                    }
                    // Dim the shader if the alarm is inactive
                    .opacity(alarm.isActive ? 1.0 : 0.3)
                    // Clip the rectangle so it has nice rounded corners
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    
                    // --- THE CARD CONTENT (Text and Toggle) ---
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(alarm.time, format: .dateTime.hour().minute())
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(alarm.isActive ? .white : .gray)
                            
                            Text(alarm.name.isEmpty ? "New Session" : alarm.name)
                                .font(.subheadline)
                                .foregroundColor(alarm.isActive ? .white.opacity(0.8) : .gray.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        // The on/off switch for the alarm
                        Toggle("", isOn: $alarm.isActive)
                            .labelsHidden()
                            // Optional: Make the toggle match your Frequence cyan color
                            .tint(.cyan)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        // Force the geometry reader to be exactly 100 points tall
        .frame(height: 150)
    }
}
