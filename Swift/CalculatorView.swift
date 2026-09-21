//
//  CalculatorView.swift
//  Timelapse
//

import SwiftUI

extension Color {
    /// Leica logo red (approx. Pantone 485 / #ED1C24).
    static let leicaRed = Color(red: 0.929, green: 0.110, blue: 0.141)
}

struct CalculatorView: View {
    @State private var store = CalculatorStore()
    @State private var showSettings = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case interval, shots, fps
    }

    var body: some View {
        ZStack {
            background
            ScrollView {
                VStack(spacing: 20) {
                    intervalModeButton
                    inputCluster
                    durationCard(title: "Shooting") {
                        DurationWheels(columns: ShootingDuration.wheels, value: store.shooting) { next in
                            animate { store.setShooting(next) }
                        }
                    }
                    durationCard(title: "Playback") {
                        DurationWheels(columns: PlaybackDuration.wheels(fps: store.fps), value: store.playback) { next in
                            animate { store.setPlayback(next) }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
        .safeAreaInset(edge: .bottom) {
            toolbar
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(store: store)
        }
        .onTapGesture {
            focusedField = nil
        }
        .onAppear {
            LeicaClick.prepare()
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(red: 0.38, green: 0.40, blue: 0.44),
                Color(red: 0.16, green: 0.17, blue: 0.20),
                Color(red: 0.03, green: 0.03, blue: 0.04)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var intervalModeButton: some View {
        Button(action: toggleIntervalMode) {
            Text(store.intervalMode ? "Interval mode on" : "Interval mode off")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(store.intervalMode ? .white : .white.opacity(0.45))
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background {
                    if store.intervalMode {
                        Capsule().fill(Color.leicaRed)
                    }
                }
        }
        .buttonStyle(.plain)
        .glassEffect(store.intervalMode ? .identity : .regular.interactive(), in: .capsule)
        .fixedSize()
        .frame(maxWidth: .infinity)
        .accessibilityLabel("Interval mode")
        .accessibilityValue(store.intervalMode ? "On" : "Off")
    }

    private var inputCluster: some View {
        GlassEffectContainer(spacing: 20) {
            HStack(spacing: 12) {
                numberField(
                    title: "Interval",
                    value: store.interval,
                    field: .interval,
                    showsIntervalIndicator: true
                ) { value in animate { store.setInterval(value) } }
                .onTapGesture(count: 2) {
                    toggleIntervalMode()
                }

                numberField(
                    title: "Shots",
                    value: store.shots,
                    field: .shots
                ) { value in animate { store.setShots(value) } }

                numberField(
                    title: "FPS",
                    value: store.fps,
                    field: .fps
                ) { value in animate { store.setFPS(value) } }
            }
        }
    }

    private func numberField(
        title: String,
        value: Int,
        field: Field,
        showsIntervalIndicator: Bool = false,
        onChange: @escaping (Int) -> Void
    ) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                if showsIntervalIndicator && store.intervalMode {
                    Circle()
                        .fill(.white)
                        .frame(width: 7, height: 7)
                }
            }
            TextField("0", value: Binding(
                get: { value },
                set: onChange
            ), format: .number)
            .keyboardType(.numberPad)
            .focused($focusedField, equals: field)
            .multilineTextAlignment(.center)
            .font(.title2.monospacedDigit().weight(.semibold))
            .foregroundStyle(.white)
            .textFieldStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .glassEffect(
            store.intervalMode && showsIntervalIndicator
                ? .regular.tint(.leicaRed.opacity(0.7)).interactive()
                : .regular.interactive(),
            in: .rect(cornerRadius: 22)
        )
    }

    private func durationCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
            content()
                .frame(height: 148)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.top, 16)
        .padding(.bottom, 10)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 28))
    }

    private var toolbar: some View {
        GlassEffectContainer(spacing: 16) {
            HStack(spacing: 12) {
                Button("Reset") {
                    focusedField = nil
                    animate { store.reset() }
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 22)
                .padding(.vertical, 14)
                .background(Color.leicaRed, in: Capsule())
                .buttonStyle(.plain)

                Spacer(minLength: 0)

                ShareLink(
                    item: store.shareText,
                    subject: Text("Timelapse calculations")
                ) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body.weight(.semibold))
                        .padding(.horizontal, 22)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .capsule)

                Button {
                    focusedField = nil
                    showSettings = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.body.weight(.semibold))
                        .padding(.horizontal, 22)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .capsule)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    private func toggleIntervalMode() {
        LeicaClick.playShutter()
        withAnimation(.snappy(duration: 0.28)) {
            store.toggleIntervalMode()
        }
    }

    private func animate(_ updates: () -> Void) {
        withAnimation(.snappy(duration: 0.42)) {
            updates()
        }
    }
}

private struct DurationWheelColumn<Value>: Identifiable {
    let unit: String
    let range: Range<Int>
    let keyPath: WritableKeyPath<Value, Int>

    var id: String { unit }
}

private struct DurationWheels<Value>: View {
    let columns: [DurationWheelColumn<Value>]
    let value: Value
    let onChange: (Value) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(columns) { column in
                wheel(column.unit, range: column.range, value: value[keyPath: column.keyPath]) { newValue in
                    var next = value
                    next[keyPath: column.keyPath] = newValue
                    onChange(next)
                }
            }
        }
    }
}

private func wheel(_ unit: String, range: Range<Int>, value: Int, onChange: @escaping (Int) -> Void) -> some View {
    VStack(spacing: 2) {
        Picker(unit, selection: Binding(
            get: { value },
            set: { newValue in
                LeicaClick.play()
                onChange(newValue)
            }
        )) {
            ForEach(Array(range), id: \.self) { value in
                Text("\(value)")
                    .tag(value)
            }
        }
        .pickerStyle(.wheel)
        .labelsHidden()
        .frame(maxWidth: .infinity)
        Text(unit)
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
    .frame(maxWidth: .infinity)
}

private extension ShootingDuration {
    static var wheels: [DurationWheelColumn<ShootingDuration>] {
        [
            DurationWheelColumn(unit: "days", range: 0..<100, keyPath: \.days),
            DurationWheelColumn(unit: "hours", range: 0..<24, keyPath: \.hours),
            DurationWheelColumn(unit: "mins", range: 0..<60, keyPath: \.minutes),
            DurationWheelColumn(unit: "secs", range: 0..<60, keyPath: \.seconds)
        ]
    }
}

private extension PlaybackDuration {
    static func wheels(fps: Int) -> [DurationWheelColumn<PlaybackDuration>] {
        [
            DurationWheelColumn(unit: "hours", range: 0..<24, keyPath: \.hours),
            DurationWheelColumn(unit: "mins", range: 0..<60, keyPath: \.minutes),
            DurationWheelColumn(unit: "secs", range: 0..<60, keyPath: \.seconds),
            DurationWheelColumn(unit: "frames", range: fps > 0 ? 0..<fps : 0..<1, keyPath: \.frames)
        ]
    }
}

#Preview("Calculator") {
    CalculatorView()
}
