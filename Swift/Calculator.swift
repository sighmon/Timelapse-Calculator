//
//  Calculator.swift
//  Timelapse
//
//  Integer calculator extracted from MainViewController.m (Dan Thompson / Simon Loffler).
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
}

enum Calculator {
    static func shootingDuration(shots: Int, interval: Int) -> ShootingDuration {
        guard interval > 0 else { return .zero }
        let totalRealSeconds = shots * interval
        let totalRealMinutes = totalRealSeconds / 60
        let totalRealHours = totalRealMinutes / 60
        let totalRealDays = totalRealHours / 24
        let totalRealHoursRemainder = totalRealHours % 24
        let totalRealMinutesRemainder = totalRealMinutes % 60
        let totalRealSecondsRemainder = totalRealSeconds % 60
        return ShootingDuration(
            days: totalRealDays,
            hours: totalRealHoursRemainder,
            minutes: totalRealMinutesRemainder,
            seconds: totalRealSecondsRemainder
        )
    }

    static func playbackDuration(shots: Int, fps: Int) -> PlaybackDuration {
        guard fps > 0 else { return .zero }
        let totalPlaybackSeconds = shots / fps
        let totalPlaybackMinutes = totalPlaybackSeconds / 60
        let totalPlaybackHours = totalPlaybackMinutes / 60
        let totalPlaybackMinutesRemainder = totalPlaybackMinutes % 60
        let totalPlaybackSecondsRemainder = totalPlaybackSeconds % 60
        let totalPlaybackFrames = shots % fps
        return PlaybackDuration(
            hours: totalPlaybackHours,
            minutes: totalPlaybackMinutesRemainder,
            seconds: totalPlaybackSecondsRemainder,
            frames: totalPlaybackFrames
        )
    }

    static func shotsFromShooting(days: Int, hours: Int, minutes: Int, seconds: Int, interval: Int) -> Int {
        guard interval > 0 else { return 0 }
        let secondsTotal = (days * 24 * 60 * 60) + (hours * 60 * 60) + (minutes * 60) + seconds
        return secondsTotal / interval
    }

    static func shotsFromPlayback(hours: Int, minutes: Int, seconds: Int, frames: Int, fps: Int) -> Int {
        (hours * (60 * 60 * fps)) + (minutes * (60 * fps)) + (seconds * fps) + frames
    }

    static func intervalFromShooting(days: Int, hours: Int, minutes: Int, seconds: Int, shots: Int) -> Int {
        guard shots > 0 else { return 0 }
        let secondsTotal = (days * 24 * 60 * 60) + (hours * 60 * 60) + (minutes * 60) + seconds
        return secondsTotal / shots
    }

    static func intervalAndShotsFromPlayback(
        hours: Int,
        minutes: Int,
        seconds: Int,
        frames: Int,
        fps: Int,
        shootingDays: Int,
        shootingHours: Int,
        shootingMinutes: Int,
        shootingSeconds: Int
    ) -> (shots: Int, interval: Int) {
        let totalPlaybackSeconds = (hours * 60 * 60) + (minutes * 60) + seconds
        let shots = totalPlaybackSeconds * fps
        let totalShootingSeconds = (shootingDays * 24 * 60 * 60) + (shootingHours * 60 * 60) + (shootingMinutes * 60) + shootingSeconds
        let interval = shots > 0 ? totalShootingSeconds / shots : 0
        return (shots, interval)
    }

    static func phrase(days: Int, hours: Int, minutes: Int, seconds: Int, frames: Int) -> String {
        var result = ""
        var comma = false

        if days > 0 {
            result += "\(days) day\(days == 1 ? "" : "s")"
            comma = true
        }
        if hours > 0 {
            let and = minutes == 0 && seconds == 0 && frames == 0
            result += "\(comma ? (and ? " and " : ", ") : "")\(hours) hour\(hours == 1 ? "" : "s")"
            comma = true
        }
        if minutes > 0 {
            let and = seconds == 0 && frames == 0
            result += "\(comma ? (and ? " and " : ", ") : "")\(minutes) minute\(minutes == 1 ? "" : "s")"
            comma = true
        }
        if seconds > 0 {
            let and = frames == 0
            result += "\(comma ? (and ? " and " : ", ") : "")\(seconds) second\(seconds == 1 ? "" : "s")"
            comma = true
        }
        if frames > 0 {
            result += "\(comma ? " and " : "")\(frames) frame\(frames == 1 ? "" : "s")"
        }
        return result
    }

    static func shareSummary(
        shots: Int,
        interval: Int,
        fps: Int,
        shooting: ShootingDuration,
        playback: PlaybackDuration
    ) -> String {
        let shootingPhrase = phrase(
            days: shooting.days,
            hours: shooting.hours,
            minutes: shooting.minutes,
            seconds: shooting.seconds,
            frames: 0
        )
        let playbackPhrase = phrase(
            days: 0,
            hours: playback.hours,
            minutes: playback.minutes,
            seconds: playback.seconds,
            frames: playback.frames
        )
        return "Shooting duration of \(shots) shots at an interval of \(interval) seconds will be \(shootingPhrase). \n\nPlayback duration of \(shots) shots at \(fps) frames per second will be \(playbackPhrase)."
    }
}
