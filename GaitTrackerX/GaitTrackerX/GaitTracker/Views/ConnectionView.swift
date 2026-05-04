import SwiftUI
import CoreBluetooth

struct ConnectionView: View {
    @EnvironmentObject var bleManager: BLEManager

    var body: some View {
        NavigationView {
            ZStack {
                Color(.init(white: 0.96, alpha: 1)).ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Icon with animated rings
                    ZStack {
                        if bleManager.isScanning {
                            Circle()
                                .stroke(Color.blue.opacity(0.15), lineWidth: 2)
                                .frame(width: 140, height: 140)
                            Circle()
                                .stroke(Color.blue.opacity(0.25), lineWidth: 2)
                                .frame(width: 110, height: 110)
                        }
                        Circle()
                            .fill(
                                LinearGradient(colors: [Color.blue, Color.blue.opacity(0.7)],
                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 88, height: 88)
                            .shadow(color: .blue.opacity(0.4), radius: 16, x: 0, y: 6)

                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                               value: bleManager.isScanning)
                    .padding(.bottom, 28)

                    Text("GaitTracker")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .padding(.bottom, 8)

                    Text(bleManager.statusMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 32)

                    // Device list
                    if !bleManager.discoveredDevices.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(bleManager.discoveredDevices, id: \.identifier) { device in
                                DeviceRow(device: device)
                                    .onTapGesture {
                                        bleManager.connect(to: device)
                                    }
                                if device.identifier != bleManager.discoveredDevices.last?.identifier {
                                    Divider().padding(.leading, 60)
                                }
                            }
                        }
                        .background(.background)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 3)
                        .padding(.horizontal)
                        .padding(.bottom, 24)
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
                        HStack(spacing: 10) {
                            if bleManager.isScanning {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(bleManager.isScanning ? "Stop Scanning" : "Scan for Device")
                                .fontWeight(.semibold)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: bleManager.isScanning
                                    ? [Color.red, Color.red.opacity(0.8)]
                                    : [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: (bleManager.isScanning ? Color.red : Color.blue).opacity(0.35),
                                radius: 8, x: 0, y: 4)
                        .padding(.horizontal)
                    }

                    Text("Make sure your GaitTracker is powered on")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 12)
                        .padding(.bottom, 28)
                }
            }
            .navigationTitle("Connect")
        }
    }
}

struct DeviceRow: View {
    let device: CBPeripheral

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 42, height: 42)
                Image(systemName: "sensor.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(device.name ?? "GaitTracker")
                    .fontWeight(.semibold)
                Text("Tap to connect")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
