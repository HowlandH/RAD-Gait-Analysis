import SwiftUI

struct SettingsView: View {
    @AppStorage("legLength") private var legLength: Double = 0.90
    @AppStorage("useImperial") private var useImperial: Bool = false
    @AppStorage("hapticFeedback") private var hapticFeedback: Bool = true
    @EnvironmentObject var dataManager: DataManager
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationView {
            Form {
                // Calibration
                Section(header: Text("Calibration")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Leg Length")
                            Spacer()
                            Text(String(format: "%.2f m", legLength))
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $legLength, in: 0.6...1.1, step: 0.01)
                            .tint(.blue)
                        Text("Measure from hip bone to ground. Used for stride calculation.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                // Preferences
                Section(header: Text("Preferences")) {
                    Toggle("Use Imperial Units", isOn: $useImperial)
                    Toggle("Haptic Feedback on Strike", isOn: $hapticFeedback)
                }

                // Cadence Guide
                Section(header: Text("Cadence Guide")) {
                    CadenceGuideRow(range: "< 160", label: "Too slow", color: .red)
                    CadenceGuideRow(range: "160-169", label: "Below optimal", color: .orange)
                    CadenceGuideRow(range: "170-180", label: "Optimal range", color: .green)
                    CadenceGuideRow(range: "> 180", label: "Fast cadence", color: .blue)
                }

                // Strike Guide
                Section(header: Text("Foot Strike Guide")) {
                    StrikeGuideRow(type: .heel)
                    StrikeGuideRow(type: .midfoot)
                    StrikeGuideRow(type: .forefoot)
                }

                // Data
                Section(header: Text("Data")) {
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Delete All Run History", systemImage: "trash")
                    }
                }

                // About
                Section(header: Text("About")) {
                    HStack {
                        Text("Device")
                        Spacer()
                        Text("GaitTracker")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Project")
                        Spacer()
                        Text("RAD Gait Analysis")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Delete All History?", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    dataManager.runHistory.removeAll()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all run records.")
            }
        }
    }
}

struct CadenceGuideRow: View {
    let range: String
    let label: String
    let color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(range)
                .fontWeight(.medium)
                .frame(width: 80, alignment: .leading)
            Text(label)
                .foregroundColor(.secondary)
        }
    }
}

struct StrikeGuideRow: View {
    let type: StrikeType

    private var color: Color {
        switch type {
        case .heel:     return .red
        case .midfoot:  return .yellow
        case .forefoot: return .green
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
                .padding(.top, 4)
            VStack(alignment: .leading, spacing: 2) {
                Text(type.description)
                    .fontWeight(.medium)
                Text(type.advice)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
