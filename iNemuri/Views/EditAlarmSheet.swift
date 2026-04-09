import SwiftUI

struct EditAlarmSheet: View {
    @Environment(\.dismiss) var dismiss
    
    // We edit a "draft" so if the user hits Cancel, we don't accidentally save half-typed changes
    @State private var draftAlarm: AlarmItem
    @State private var selectedSound: String = "Chime"
    
    // The closure that sends the saved data back to the Home Page
    var onSave: (AlarmItem) -> Void
    
    // Your library of future Metal shaders!
    let availableDesigns = [
        "defaultFrequenceShader",
        "liquidMetalLoop",
        "hinomaru_shader",
        "bioluminescent_moon",
        "zen_mandala",
        "synthwaveFragment"
    ]
    
    // Available sound options
    let availableSounds = [
        "Chime",
        "Beacon",
        "Circuit",
        "Hillside",
        "Radiate",
        "Signal",
        "Waves"
    ]
    
    init(alarm: AlarmItem, onSave: @escaping (AlarmItem) -> Void) {
        self._draftAlarm = State(initialValue: alarm)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // 1. Time Picker
                Section {
                    DatePicker("Time", selection: $draftAlarm.time, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                // 2. Details
                Section {
                    TextField("Alarm Name", text: $draftAlarm.name)
                    Stepper("Snooze: \(draftAlarm.snoozeTime) mins", value: $draftAlarm.snoozeTime, in: 1...30)
                }
                
                // 3. The Metal Design Picker!
                Section(header: Text("Card Appearance")) {
                    Picker("Theme Design", selection: $draftAlarm.shaderName) {
                        ForEach(availableDesigns, id: \.self) { designName in
                            // You can format these names later so they look prettier to the user
                            Text(designName).tag(designName)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // 4. Sound Picker
                Section(header: Text("Sound")) {
                    Picker("Sound", selection: $selectedSound) {
                        ForEach(availableSounds, id: \.self) { soundName in
                            Text(soundName).tag(soundName)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // 5. Schedule Placeholder (You can expand this to 7 toggle buttons later)
                Section(header: Text("Schedule")) {
                    Text("Selected Days: \(draftAlarm.schedule.count)")
                        .foregroundColor(.secondary)
                }
            }
            
            .navigationTitle(draftAlarm.name.isEmpty ? "New Session" : "Edit Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // TODO: Assign selectedSound back to draftAlarm's sound property when available, e.g., draftAlarm.sound = selectedSound
                        onSave(draftAlarm) // Send the data back!
                        dismiss()
                    }
                }
            }
        }
    }
}
