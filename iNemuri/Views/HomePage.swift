import SwiftUI

struct HomePage: View {
    @State private var AlarmCards: [AlarmItem] = []
    @State private var alarmToEdit: AlarmItem?
    
    @State private var activeShader: ActiveShader?
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(spacing: 16) {
                    ForEach($AlarmCards) { $alarmCard in
                        AlarmCard(alarm: $alarmCard)
                            .visualEffect { content, proxy in
                                content.hueRotation(
                                    Angle(degrees: proxy.frame(in: .global).origin.y / 10)
                                )
                            }
                            .onTapGesture {
                                alarmToEdit = alarmCard
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("Frequence")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            // NEW: This single line safely triggers the full screen cover and passes the data
                            activeShader = ActiveShader(name: getNearestAlarmShader())
                        }) {
                            Image(systemName: "moon.zzz.fill")
                                .fontWeight(.bold)
                                .foregroundColor(.indigo)
                        }
                    }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addNewAlarm) {
                        Image(systemName: "plus").fontWeight(.bold)
                    }
                }
            }
            .sheet(item: $alarmToEdit) { selectedAlarm in
                EditAlarmSheet(alarm: selectedAlarm) { updatedAlarm in
                    saveChanges(updatedAlarm)
                }
            }
            // NEW: Watches for 'activeShader'. When it exists, it safely unwraps it as 'shader'
                .fullScreenCover(item: $activeShader) { shader in
                    ContentView(shaderName: shader.name)
                }
        }
    }
    
    private func getNearestAlarmShader() -> String {
        let now = Date()
        let upcomingAlarms = AlarmCards.filter { $0.isActive && $0.time > now }
        let sortedAlarms = upcomingAlarms.sorted { $0.time < $1.time }
        
        print("Total Alarms: \(AlarmCards.count)")
                print("Upcoming Active Alarms: \(upcomingAlarms.count)")
                print("Selected Shader: \(sortedAlarms.first?.shaderName ?? "None! Defaulting...")")
        
        
        return sortedAlarms.first?.shaderName ?? "synthwaveFragment"
    }
    
    private func addNewAlarm() {
        let newCard = AlarmItem(
            time: Date(), name: "New Session", schedule: [],
            // UPDATED: Default shader changed to match your new library
            snoozeTime: 5, isActive: true, shaderName: "synthwaveFragment"
        )
        withAnimation(.spring()) {
            AlarmCards.append(newCard)
        }
    }
    
    private func saveChanges(_ updatedAlarm: AlarmItem) {
        if let index = AlarmCards.firstIndex(where: { $0.id == updatedAlarm.id }) {
            AlarmCards[index] = updatedAlarm
        }
    }
}

struct ActiveShader: Identifiable {
    var id: String { name }
    var name: String
}

#Preview {
    HomePage()
}
