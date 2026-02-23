import SwiftUI
import UIKit

struct HistoryView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingExportSheet = false
    @State private var csvContent = ""

    var body: some View {
        NavigationView {
            Group {
                if dataManager.runHistory.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.badge.xmark")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No runs yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Complete a run to see your history here")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(dataManager.runHistory) { run in
                            RunHistoryRow(run: run)
                        }
                        .onDelete { offsets in
                            dataManager.delete(at: offsets)
                        }
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !dataManager.runHistory.isEmpty {
                        Button(action: {
                            csvContent = dataManager.exportCSV()
                            showingExportSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                ShareSheet(items: [csvContent])
            }
        }
    }
}

struct RunHistoryRow: View {
    let run: RunRecord

    private var strikeColor: Color {
        switch run.strikeType {
        case .heel:     return .red
        case .midfoot:  return .yellow
        case .forefoot: return .green
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(run.dateFormatted)
                    .font(.headline)
                Spacer()
                Circle()
                    .fill(strikeColor)
                    .frame(width: 10, height: 10)
                Text(run.strikeType.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 20) {
                StatItem(label: "Distance", value: run.distanceFormatted)
                StatItem(label: "Duration", value: run.durationFormatted)
                StatItem(label: "Cadence", value: "\(run.averageCadence) spm")
                StatItem(label: "Steps", value: "\(run.stepCount)")
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
