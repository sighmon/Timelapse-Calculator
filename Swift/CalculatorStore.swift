//
//  CalculatorStore.swift
//  Timelapse
//

import Foundation
import SwiftUI

@Observable
final class CalculatorStore {
    enum Keys {
        static let interval = "interval"
        static let shots = "shots"
        static let fps = "fps"
        static let intervalToggle = "defaultIntervalToggle"
    }

    var interval: Int
    var shots: Int
    var fps: Int
    var intervalMode: Bool
    var shooting: ShootingDuration
    var playback: PlaybackDuration

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        Self.registerDefaults(in: defaults)
        interval = Self.int(for: Keys.interval, in: defaults, fallback: 60)
        shots = Self.int(for: Keys.shots, in: defaults, fallback: 1500)
        fps = Self.int(for: Keys.fps, in: defaults, fallback: 25)
        intervalMode = defaults.bool(forKey: Keys.intervalToggle)
        shooting = .zero
        playback = .zero
        applySettingsCentric()
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

    var frameRange: Range<Int> {
        fps > 0 ? 0..<fps : 0..<1
    }

    func reset() {
        interval = Self.int(for: Keys.interval, in: defaults, fallback: 60)
        shots = Self.int(for: Keys.shots, in: defaults, fallback: 1500)
        fps = Self.int(for: Keys.fps, in: defaults, fallback: 25)
        intervalMode = defaults.bool(forKey: Keys.intervalToggle)
        applySettingsCentric()
    }

    func toggleIntervalMode() {
        intervalMode.toggle()
        defaults.set(intervalMode, forKey: Keys.intervalToggle)
    }

    func setInterval(_ value: Int) {
        interval = max(0, value)
        applySettingsCentric()
    }

    func setShots(_ value: Int) {
        shots = max(0, value)
        applySettingsCentric()
    }

    func setFPS(_ value: Int) {
        fps = max(0, value)
        applySettingsCentric()
    }

    func setShooting(days: Int? = nil, hours: Int? = nil, minutes: Int? = nil, seconds: Int? = nil) {
        if let days { shooting.days = days }
        if let hours { shooting.hours = hours }
        if let minutes { shooting.minutes = minutes }
        if let seconds { shooting.seconds = seconds }
        applyShootWheel()
    }

    func setPlayback(hours: Int? = nil, minutes: Int? = nil, seconds: Int? = nil, frames: Int? = nil) {
        if let hours { playback.hours = hours }
        if let minutes { playback.minutes = minutes }
        if let seconds { playback.seconds = seconds }
        if let frames { playback.frames = frames }
        applyPlaybackWheel()
    }

    func saveDefaults(interval: Int, shots: Int, fps: Int, intervalMode: Bool) {
        defaults.set(String(max(0, interval)), forKey: Keys.interval)
        defaults.set(String(max(0, shots)), forKey: Keys.shots)
        defaults.set(String(max(0, fps)), forKey: Keys.fps)
        defaults.set(intervalMode, forKey: Keys.intervalToggle)
    }

    func loadSavedDefaults() -> (interval: Int, shots: Int, fps: Int, intervalMode: Bool) {
        (
            Self.int(for: Keys.interval, in: defaults, fallback: 60),
            Self.int(for: Keys.shots, in: defaults, fallback: 1500),
            Self.int(for: Keys.fps, in: defaults, fallback: 25),
            defaults.bool(forKey: Keys.intervalToggle)
        )
    }

    func applySettingsCentric() {
        animate {
            if interval > 0 {
                shooting = Calculator.shootingDuration(shots: shots, interval: interval)
            } else {
                shooting = .zero
            }
            if fps > 0 {
                playback = Calculator.playbackDuration(shots: shots, fps: fps)
                if playback.frames >= fps {
                    playback.frames = 0
                }
            } else {
                playback = .zero
            }
        }
    }

    private func applyShootWheel() {
        if intervalMode {
            if shots > 0 {
                interval = Calculator.intervalFromShooting(
                    days: shooting.days,
                    hours: shooting.hours,
                    minutes: shooting.minutes,
                    seconds: shooting.seconds,
                    shots: shots
                )
            } else {
                interval = 0
            }
            applySettingsCentric()
        } else if interval > 0 {
            animate {
                shots = Calculator.shotsFromShooting(
                    days: shooting.days,
                    hours: shooting.hours,
                    minutes: shooting.minutes,
                    seconds: shooting.seconds,
                    interval: interval
                )
                if fps > 0 {
                    playback = Calculator.playbackDuration(shots: shots, fps: fps)
                }
            }
        } else {
            shooting = .zero
        }
    }

    private func applyPlaybackWheel() {
        if intervalMode {
            if shots > 0 {
                let result = Calculator.intervalAndShotsFromPlayback(
                    hours: playback.hours,
                    minutes: playback.minutes,
                    seconds: playback.seconds,
                    frames: playback.frames,
                    fps: fps,
                    shootingDays: shooting.days,
                    shootingHours: shooting.hours,
                    shootingMinutes: shooting.minutes,
                    shootingSeconds: shooting.seconds
                )
                interval = result.interval
                shots = result.shots
            } else {
                interval = 0
            }
            applySettingsCentric()
        } else if fps > 0 {
            animate {
                shots = Calculator.shotsFromPlayback(
                    hours: playback.hours,
                    minutes: playback.minutes,
                    seconds: playback.seconds,
                    frames: playback.frames,
                    fps: fps
                )
                if interval > 0 {
                    shooting = Calculator.shootingDuration(shots: shots, interval: interval)
                }
            }
        } else {
            playback = .zero
        }
    }

    private func animate(_ updates: () -> Void) {
        withAnimation(.snappy(duration: 0.42)) {
            updates()
        }
    }

    static func registerDefaults(in defaults: UserDefaults) {
        defaults.register(defaults: [
            Keys.interval: "60",
            Keys.shots: "1500",
            Keys.fps: "25",
            Keys.intervalToggle: false
        ])
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
