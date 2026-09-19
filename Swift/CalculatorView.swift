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
            VStack(spacing: 20) {
                intervalModeButton
                inputCluster
                durationCard(title: "Shooting") {
                    ShootingDurationPicker(store: store)
                }
                durationCard(title: "Playback") {
                    PlaybackDurationPicker(store: store)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .preferredColorScheme(.dark)
        .safeAreaInset(edge: .bottom) {
            toolbar
        }
        .sheet(isPresented: $showSettings, onDismiss: { store.reset() }) {
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
        Button {
            LeicaClick.playShutter()
            withAnimation(.snappy(duration: 0.28)) {
                store.toggleIntervalMode()
            }
        } label: {
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
                ) { store.setInterval($0) }
                .onTapGesture(count: 2) {
                    LeicaClick.playShutter()
                    withAnimation(.snappy(duration: 0.28)) {
                        store.toggleIntervalMode()
                    }
                }

                numberField(
                    title: "Shots",
                    value: store.shots,
                    field: .shots
                ) { store.setShots($0) }

                numberField(
                    title: "FPS",
                    value: store.fps,
                    field: .fps
                ) { store.setFPS($0) }
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
                    store.reset()
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .toolbarButtonPadding()
                .background(Color.leicaRed, in: Capsule())
                .buttonStyle(.plain)

                Spacer(minLength: 0)

                ShareLink(
                    item: store.shareText,
                    subject: Text("Timelapse calculations")
                ) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body.weight(.semibold))
                        .toolbarButtonPadding()
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .capsule)

                Button {
                    focusedField = nil
                    showSettings = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.body.weight(.semibold))
                        .toolbarButtonPadding()
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .capsule)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }
}

private struct ToolbarButtonPadding: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 22)
            .padding(.vertical, 14)
    }
}

private extension View {
    func toolbarButtonPadding() -> some View {
        modifier(ToolbarButtonPadding())
    }
}

private struct ShootingDurationPicker: View {
    var store: CalculatorStore

    var body: some View {
        HStack(spacing: 0) {
            wheel("days", selection: Binding(
                get: { store.shooting.days },
                set: { LeicaClick.play(); store.setShooting(days: $0) }
            ), range: 0..<100)
            wheel("hours", selection: Binding(
                get: { store.shooting.hours },
                set: { LeicaClick.play(); store.setShooting(hours: $0) }
            ), range: 0..<24)
            wheel("mins", selection: Binding(
                get: { store.shooting.minutes },
                set: { LeicaClick.play(); store.setShooting(minutes: $0) }
            ), range: 0..<60)
            wheel("secs", selection: Binding(
                get: { store.shooting.seconds },
                set: { LeicaClick.play(); store.setShooting(seconds: $0) }
            ), range: 0..<60)
        }
    }
}

private struct PlaybackDurationPicker: View {
    var store: CalculatorStore

    var body: some View {
        HStack(spacing: 0) {
            wheel("hours", selection: Binding(
                get: { store.playback.hours },
                set: { LeicaClick.play(); store.setPlayback(hours: $0) }
            ), range: 0..<24)
            wheel("mins", selection: Binding(
                get: { store.playback.minutes },
                set: { LeicaClick.play(); store.setPlayback(minutes: $0) }
            ), range: 0..<60)
            wheel("secs", selection: Binding(
                get: { store.playback.seconds },
                set: { LeicaClick.play(); store.setPlayback(seconds: $0) }
            ), range: 0..<60)
            wheel("frames", selection: Binding(
                get: { min(store.playback.frames, max(store.fps - 1, 0)) },
                set: { LeicaClick.play(); store.setPlayback(frames: $0) }
            ), range: store.frameRange)
        }
    }
}

private func wheel(_ unit: String, selection: Binding<Int>, range: Range<Int>) -> some View {
    VStack(spacing: 2) {
        Picker(unit, selection: selection) {
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
