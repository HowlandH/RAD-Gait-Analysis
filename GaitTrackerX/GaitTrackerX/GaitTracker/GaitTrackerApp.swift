import SwiftUI

@main
struct GaitTrackerApp: App {
    @StateObject private var bleManager = BLEManager()
    @StateObject private var dataManager = DataManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bleManager)
                .environmentObject(dataManager)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var bleManager: BLEManager

    var body: some View {
        TabView {
            if bleManager.isConnected {
                DashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "figure.run")
                    }
            } else {
                ConnectionView()
                    .tabItem {
                        Label("Connect", systemImage: "bluetooth")
                    }
            }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
