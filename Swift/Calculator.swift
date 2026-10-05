//
//  Calculator.swift
//  Timelapse
//

import Foundation

struct ShootingDuration: Equatable {
    var days: Int
    var hours: Int
    var minutes: Int
    var seconds: Int

    static let zero = ShootingDuration(days: 0, hours: 0, minutes: 0, seconds: 0)

    var totalSeconds: Int {
        (days * 24 * 60 * 60) + (hours * 60 * 60) + (minutes * 60) + seconds
    }
}

struct PlaybackDuration: Equatable {
    var hours: Int
    var minutes: Int
    var seconds: Int
    var frames: Int

    static let zero = PlaybackDuration(hours: 0, minutes: 0, seconds: 0, frames: 0)

    var totalSeconds: Int {
        (hours * 60 * 60) + (minutes * 60) + seconds
    }

    func shotCount(fps: Int) -> Int {
        (hours * (60 * 60 * fps)) + (minutes * (60 * fps)) + (seconds * fps) + frames
    }
}

enum Calculator {
    static func shootingDuration(shots: Int, interval: Int) -> ShootingDuration {
        guard interval > 0 else { return .zero }
        let totalRealSeconds = shots * interval
        let totalRealMinutes = totalRealSeconds / 60
        let totalRealHours = totalRealMinutes / 60
        return ShootingDuration(
            days: totalRealHours / 24,
            hours: totalRealHours % 24,
            minutes: totalRealMinutes % 60,
            seconds: totalRealSeconds % 60
        )
    }

    static func playbackDuration(shots: Int, fps: Int) -> PlaybackDuration {
        guard fps > 0 else { return .zero }
        let totalPlaybackSeconds = shots / fps
        let totalPlaybackMinutes = totalPlaybackSeconds / 60
        return PlaybackDuration(
            hours: totalPlaybackMinutes / 60,
            minutes: totalPlaybackMinutes % 60,
            seconds: totalPlaybackSeconds % 60,
            frames: shots % fps
        )
    }

    static func shotsFromShooting(_ shooting: ShootingDuration, interval: Int) -> Int {
        guard interval > 0 else { return 0 }
        return shooting.totalSeconds / interval
    }

    static func shotsFromPlayback(_ playback: PlaybackDuration, fps: Int) -> Int {
        playback.shotCount(fps: fps)
    }

    static func intervalFromShooting(_ shooting: ShootingDuration, shots: Int) -> Int {
        guard shots > 0 else { return 0 }
        return shooting.totalSeconds / shots
    }

    /// Interval-mode playback uses whole seconds × fps and ignores leftover frames,
    /// matching the original calculator.
    static func intervalAndShotsFromPlayback(
        _ playback: PlaybackDuration,
        fps: Int,
        shooting: ShootingDuration
    ) -> (shots: Int, interval: Int) {
        let shots = playback.totalSeconds * fps
        let interval = shots > 0 ? shooting.totalSeconds / shots : 0
        return (shots, interval)
    }

    static func phrase(_ shooting: ShootingDuration) -> String {
        join([
            unit(shooting.days, "day"),
            unit(shooting.hours, "hour"),
            unit(shooting.minutes, "minute"),
            unit(shooting.seconds, "second")
        ])
    }

    static func phrase(_ playback: PlaybackDuration) -> String {
        join([
            unit(playback.hours, "hour"),
            unit(playback.minutes, "minute"),
            unit(playback.seconds, "second"),
            unit(playback.frames, "frame")
        ])
    }

    static func shareSummary(
        shots: Int,
        interval: Int,
        fps: Int,
        shooting: ShootingDuration,
        playback: PlaybackDuration
    ) -> String {
        "Shooting duration of \(shots) shots at an interval of \(interval) seconds will be \(phrase(shooting)). \n\nPlayback duration of \(shots) shots at \(fps) frames per second will be \(phrase(playback))."
    }

    private static func unit(_ value: Int, _ name: String) -> String? {
        guard value > 0 else { return nil }
        return "\(value) \(name)\(value == 1 ? "" : "s")"
    }

    private static func join(_ parts: [String?]) -> String {
        let parts = parts.compactMap { $0 }
        switch parts.count {
        case 0:
            return ""
        case 1:
            return parts[0]
        default:
            return parts.dropLast().joined(separator: ", ") + " and " + parts[parts.count - 1]
        }
    }
}
