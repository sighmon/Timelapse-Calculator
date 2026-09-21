//
//  CalculatorStore.swift
//  Timelapse
//

import Foundation

struct SavedDefaults: Equatable {
    var interval: Int
    var shots: Int
    var fps: Int
    var intervalMode: Bool

    static let fallback = SavedDefaults(interval: 60, shots: 1500, fps: 25, intervalMode: false)

    static func register(in defaults: UserDefaults) {
        defaults.register(defaults: [
            CalculatorStore.Keys.interval: "60",
            CalculatorStore.Keys.shots: "1500",
            CalculatorStore.Keys.fps: "25",
            CalculatorStore.Keys.intervalToggle: false
        ])
    }

    static func load(from defaults: UserDefaults) -> SavedDefaults {
        SavedDefaults(
            interval: int(for: CalculatorStore.Keys.interval, in: defaults, fallback: fallback.interval),
            shots: int(for: CalculatorStore.Keys.shots, in: defaults, fallback: fallback.shots),
            fps: int(for: CalculatorStore.Keys.fps, in: defaults, fallback: fallback.fps),
            intervalMode: defaults.bool(forKey: CalculatorStore.Keys.intervalToggle)
        )
    }

    func save(to defaults: UserDefaults) {
        defaults.set(String(max(0, interval)), forKey: CalculatorStore.Keys.interval)
        defaults.set(String(max(0, shots)), forKey: CalculatorStore.Keys.shots)
        defaults.set(String(max(0, fps)), forKey: CalculatorStore.Keys.fps)
        defaults.set(intervalMode, forKey: CalculatorStore.Keys.intervalToggle)
    }

    private static func int(for key: String, in defaults: UserDefaults, fallback: Int) -> Int {
        if let string = defaults.string(forKey: key), let value = Int(string) {
            return value
        }
        if let number = defaults.object(forKey: key) as? NSNumber {
            return number.intValue
        }
        return fallback
    }
}

@Observable
final class CalculatorStore {
    enum Keys {
        static let interval = "interval"
        static let shots = "shots"
        static let fps = "fps"
        static let intervalToggle = "defaultIntervalToggle"
    }

    private(set) var interval: Int
    private(set) var shots: Int
    private(set) var fps: Int
    private(set) var intervalMode: Bool
    private(set) var shooting: ShootingDuration
    private(set) var playback: PlaybackDuration

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        SavedDefaults.register(in: defaults)
        let saved = SavedDefaults.load(from: defaults)
        interval = saved.interval
        shots = saved.shots
        fps = saved.fps
        intervalMode = saved.intervalMode
        shooting = .zero
        playback = .zero
        syncFromSettings()
    }

    var shareText: String {
        Calculator.shareSummary(
            shots: shots,
            interval: interval,
            fps: fps,
            shooting: shooting,
            playback: playback
        )
    }

    var savedDefaults: SavedDefaults {
        SavedDefaults.load(from: defaults)
    }

    func reset() {
        apply(SavedDefaults.load(from: defaults))
    }

    func saveDefaults(_ saved: SavedDefaults) {
        saved.save(to: defaults)
        apply(saved)
    }

    func toggleIntervalMode() {
        intervalMode.toggle()
        defaults.set(intervalMode, forKey: Keys.intervalToggle)
    }

    func setInterval(_ value: Int) {
        interval = max(0, value)
        syncFromSettings()
    }

    func setShots(_ value: Int) {
        shots = max(0, value)
        syncFromSettings()
    }

    func setFPS(_ value: Int) {
        fps = max(0, value)
        syncFromSettings()
    }

    func setShooting(_ shooting: ShootingDuration) {
        self.shooting = shooting
        if intervalMode {
            interval = Calculator.intervalFromShooting(shooting, shots: shots)
            syncFromSettings()
        } else {
            shots = Calculator.shotsFromShooting(shooting, interval: interval)
            playback = Calculator.playbackDuration(shots: shots, fps: fps)
            if interval <= 0 {
                self.shooting = .zero
            }
        }
    }

    func setPlayback(_ playback: PlaybackDuration) {
        self.playback = playback
        if intervalMode {
            if shots > 0 {
                let result = Calculator.intervalAndShotsFromPlayback(playback, fps: fps, shooting: shooting)
                shots = result.shots
                interval = result.interval
            } else {
                interval = 0
            }
            syncFromSettings()
        } else {
            shots = Calculator.shotsFromPlayback(playback, fps: fps)
            shooting = Calculator.shootingDuration(shots: shots, interval: interval)
            if fps <= 0 {
                self.playback = .zero
            }
        }
    }

    private func apply(_ saved: SavedDefaults) {
        interval = max(0, saved.interval)
        shots = max(0, saved.shots)
        fps = max(0, saved.fps)
        intervalMode = saved.intervalMode
        syncFromSettings()
    }

    private func syncFromSettings() {
        shooting = Calculator.shootingDuration(shots: shots, interval: interval)
        playback = Calculator.playbackDuration(shots: shots, fps: fps)
    }
}
