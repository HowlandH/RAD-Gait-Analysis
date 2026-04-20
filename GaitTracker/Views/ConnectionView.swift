import SwiftUI
import CoreBluetooth

struct ConnectionView: View {
    @EnvironmentObject var bleManager: BLEManager

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()

                // Icon
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .symbolEffect(.pulse, isActive: bleManager.isScanning)

                // Title
                Text("GaitTracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Status message
                Text(bleManager.statusMessage)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Device list
                if !bleManager.discoveredDevices.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Available Devices")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.bottom, 8)

                        ForEach(bleManager.discoveredDevices, id: \.identifier) { device in
                            DeviceRow(device: device)
                                .onTapGesture {
                                    bleManager.connect(to: device)
                                }
                        }
                    }
                    .background(Color(.systemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                Spacer()

                // Scan button
                Button(action: {
                    if bleManager.isScanning {
                        bleManager.stopScanning()
                    } else {
                        bleManager.startScanning()
                    }
                }) {
                    HStack {
                        if bleManager.isScanning {
                            ProgressView()
                                .tint(.white)
                                .padding(.trailing, 4)
                        }
                        Text(bleManager.isScanning ? "Stop Scanning" : "Scan for Device")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(bleManager.isScanning ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .padding(.horizontal)
                }

                Text("Make sure your GaitTracker is powered on")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
            .navigationTitle("Connect")
        }
    }
}

struct DeviceRow: View {
    let device: CBPeripheral

    var body: some View {
        HStack {
            Image(systemName: "sensor.fill")
                .foregroundColor(.blue)
                .frame(width: 36, height: 36)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)

            VStack(alignment: .leading) {
                Text(device.name ?? "Unknown Device")
                    .fontWeight(.medium)
                Text(device.identifier.uuidString.prefix(8) + "...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
