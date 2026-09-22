//
//  SettingsView.swift
//  Timelapse
//

import SwiftUI

struct SettingsView: View {
    var store: CalculatorStore
    @Environment(\.dismiss) private var dismiss
    @State private var draft = SavedDefaults.fallback

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    defaultsCard
                    creditsCard
                    versionLabel
                }
                .padding(20)
            }
            .background(Color.black.opacity(0.35).ignoresSafeArea())
            .navigationTitle("Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        withAnimation(.snappy(duration: 0.42)) {
                            store.saveDefaults(draft)
                        }
                        dismiss()
                    }
                    .adaptiveProminentButtonStyle()
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            draft = store.savedDefaults
        }
    }

    private var defaultsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Default settings")
                .font(.headline)
            defaultField("Interval", value: $draft.interval)
            defaultField("Shots", value: $draft.shots)
            defaultField("FPS", value: $draft.fps)
            Toggle("Interval Calculations", isOn: $draft.intervalMode)
                .tint(.red)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .adaptiveGlass(in: RoundedRectangle(cornerRadius: 28), interactive: false)
    }

    private func defaultField(_ title: String, value: Binding<Int>) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField("0", value: value, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(.body.monospacedDigit())
                .frame(width: 96)
                .textFieldStyle(.plain)
        }
    }

    private var creditsCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Credits")
                .font(.headline)

            Text("Thanks for downloading this app. It's free software under a GPL license.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Link("Source on GitHub", destination: URL(string: "https://github.com/sighmon/Timelapse-Calculator")!)
            Link("Original math at openmoco.org", destination: URL(string: "http://openmoco.org/node/295")!)

            creditRow(image: "si", name: "Simon Loffler", detail: "This is me, the guy responsible for this app.", url: "http://sighmon.com")
            creditRow(image: "dan", name: "Dan Thompson", detail: "Wrote the original python code for PC.", url: "http://danthompsonsblog.blogspot.com/search/label/Timelapse")
            creditRow(image: "pix", name: "Pix", detail: "Special thanks for volunteering time to debug and optimise the code.", url: "http://thatpixguy.com")
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .adaptiveGlass(in: RoundedRectangle(cornerRadius: 28), interactive: false)
    }

    private func creditRow(image: String, name: String, detail: String, url: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            creditImage(image)
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Link(url.replacingOccurrences(of: "http://", with: ""), destination: URL(string: url)!)
                    .font(.caption)
            }
        }
    }

    @ViewBuilder
    private func creditImage(_ name: String) -> some View {
        if let uiImage = UIImage(named: name) {
            Image(uiImage: uiImage)
                .resizable()
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .foregroundStyle(.secondary)
        }
    }

    private var versionLabel: some View {
        Text(versionText)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
    }

    private var versionText: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.3"
        let build = info?["CFBundleVersion"] as? String ?? "9"
        return "Version \(version) (\(build))"
    }
}

#Preview("Settings") {
    SettingsView(store: CalculatorStore(defaults: UserDefaults(suiteName: "SettingsPreview")!))
}
