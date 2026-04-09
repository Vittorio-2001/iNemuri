import SwiftUI

struct ContentView: View {
    // The view expects a shader name to know which background to draw
    var shaderName: String
    
    let startDate = Date()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .center) {
            
            GeometryReader { geometry in
                TimelineView(.animation) { context in
                    let elapsedTime = context.date.timeIntervalSince(startDate)
                    
                    // Route to the correct shader based on the string
                    shaderBackground(
                        name: shaderName,
                        time: elapsedTime,
                        size: geometry.size
                    )
                    .ignoresSafeArea()
                }
            }
            
            ClockView()
            
        }
        // Tap anywhere to exit Bed Clock Mode
        .onTapGesture {
            dismiss()
        }
    }
    
    // THE SHADER ROUTER
    // This perfectly matches the file/function names in your Metal folder
    @ViewBuilder
    private func shaderBackground(name: String, time: TimeInterval, size: CGSize) -> some View {
        let rect = Rectangle()
        
        switch name {
        case "bioluminescent_moon":
            rect.colorEffect(ShaderLibrary.bioluminescent_moon(.float(time), .float2(size)))
            
        case "hinomaru_shader":
            rect.colorEffect(ShaderLibrary.hinomaru_shader(.float(time), .float2(size)))
            
        case "liquidMetalLoop":
            rect.colorEffect(ShaderLibrary.liquidMetalLoop(.float(time), .float2(size)))
            
        case "movingBackground":
            rect.colorEffect(ShaderLibrary.movingBackground(.float(time), .float2(size)))
            
        case "zen_mandala":
            rect.colorEffect(ShaderLibrary.zen_mandala(.float(time), .float2(size)))
            
        case "synthwaveFragment":
            rect.colorEffect(ShaderLibrary.synthwaveFragment(.float(time), .float2(size)))
            
        default:
            // Safe fallback if a name is misspelled
            rect.colorEffect(ShaderLibrary.synthwaveFragment(.float(time), .float2(size)))
        }
    }
}

#Preview {
    ContentView(shaderName: "synthwaveFragment")
}
