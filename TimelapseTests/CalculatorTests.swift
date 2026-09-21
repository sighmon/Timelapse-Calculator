//
//  CalculatorTests.swift
//  TimelapseTests
//
//  Drives the shipped Calculator transforms — not a reimplementation.
//

import XCTest
@testable import Timelapse

final class CalculatorTests: XCTestCase {
    func testSettingsCentric120Shots60s25fps() {
        let shooting = Calculator.shootingDuration(shots: 120, interval: 60)
        XCTAssertEqual(shooting, ShootingDuration(days: 0, hours: 2, minutes: 0, seconds: 0))

        let playback = Calculator.playbackDuration(shots: 120, fps: 25)
        XCTAssertEqual(playback, PlaybackDuration(hours: 0, minutes: 0, seconds: 4, frames: 20))
    }

    func testSettingsCentric1500Shots10s30fps() {
        let shooting = Calculator.shootingDuration(shots: 1500, interval: 10)
        XCTAssertEqual(shooting, ShootingDuration(days: 0, hours: 4, minutes: 10, seconds: 0))

        let playback = Calculator.playbackDuration(shots: 1500, fps: 30)
        XCTAssertEqual(playback, PlaybackDuration(hours: 0, minutes: 0, seconds: 50, frames: 0))
    }

    func testShootCentricTwoHoursAt60s25fps() {
        let shots = Calculator.shotsFromShooting(
            ShootingDuration(days: 0, hours: 2, minutes: 0, seconds: 0),
            interval: 60
        )
        XCTAssertEqual(shots, 120)

        let playback = Calculator.playbackDuration(shots: shots, fps: 25)
        XCTAssertEqual(playback.seconds, 4)
        XCTAssertEqual(playback.frames, 20)
    }

    func testPlaybackCentric4s20fAt25fps60s() {
        let shots = Calculator.shotsFromPlayback(
            PlaybackDuration(hours: 0, minutes: 0, seconds: 4, frames: 20),
            fps: 25
        )
        XCTAssertEqual(shots, 120)

        let shooting = Calculator.shootingDuration(shots: shots, interval: 60)
        XCTAssertEqual(shooting.hours, 2)
        XCTAssertEqual(shooting.minutes, 0)
        XCTAssertEqual(shooting.seconds, 0)
    }

    func testIntervalModeShooting4h10mWith1500Shots() {
        let interval = Calculator.intervalFromShooting(
            ShootingDuration(days: 0, hours: 4, minutes: 10, seconds: 0),
            shots: 1500
        )
        XCTAssertEqual(interval, 10)
    }

    func testIntervalModePlayback50sAt30fpsWith4h10mShooting() {
        let result = Calculator.intervalAndShotsFromPlayback(
            PlaybackDuration(hours: 0, minutes: 0, seconds: 50, frames: 0),
            fps: 30,
            shooting: ShootingDuration(days: 0, hours: 4, minutes: 10, seconds: 0)
        )
        XCTAssertEqual(result.shots, 1500)
        XCTAssertEqual(result.interval, 10)
    }

    func testShareSummaryUsesOriginalWording() {
        let shooting = Calculator.shootingDuration(shots: 120, interval: 60)
        let playback = Calculator.playbackDuration(shots: 120, fps: 25)
        let text = Calculator.shareSummary(
            shots: 120,
            interval: 60,
            fps: 25,
            shooting: shooting,
            playback: playback
        )
        XCTAssertEqual(
            text,
            "Shooting duration of 120 shots at an interval of 60 seconds will be 2 hours. \n\nPlayback duration of 120 shots at 25 frames per second will be 4 seconds and 20 frames."
        )
    }

    func testStoreSettingsCentricMatchesCalculator() {
        let store = makeStore()
        store.setInterval(60)
        store.setFPS(25)
        store.setShots(120)
        XCTAssertEqual(store.shooting, Calculator.shootingDuration(shots: 120, interval: 60))
        XCTAssertEqual(store.playback, Calculator.playbackDuration(shots: 120, fps: 25))
        XCTAssertEqual(store.shareText, Calculator.shareSummary(
            shots: 120,
            interval: 60,
            fps: 25,
            shooting: store.shooting,
            playback: store.playback
        ))
    }

    func testStoreShootCentricTwoHours() {
        let store = makeStore()
        store.setInterval(60)
        store.setFPS(25)
        store.setShooting(ShootingDuration(days: 0, hours: 2, minutes: 0, seconds: 0))
        XCTAssertEqual(
            store.shots,
            Calculator.shotsFromShooting(
                ShootingDuration(days: 0, hours: 2, minutes: 0, seconds: 0),
                interval: 60
            )
        )
        XCTAssertEqual(store.shots, 120)
        XCTAssertEqual(store.playback, Calculator.playbackDuration(shots: 120, fps: 25))
    }

    func testStorePlaybackCentric4s20f() {
        let store = makeStore()
        store.setInterval(60)
        store.setFPS(25)
        store.setPlayback(PlaybackDuration(hours: 0, minutes: 0, seconds: 4, frames: 20))
        XCTAssertEqual(
            store.shots,
            Calculator.shotsFromPlayback(
                PlaybackDuration(hours: 0, minutes: 0, seconds: 4, frames: 20),
                fps: 25
            )
        )
        XCTAssertEqual(store.shots, 120)
        XCTAssertEqual(store.shooting, Calculator.shootingDuration(shots: 120, interval: 60))
    }

    func testStoreIntervalModeShootingAndPlayback() {
        let store = makeStore()
        store.setInterval(60)
        store.setFPS(30)
        store.setShots(1500)
        store.toggleIntervalMode()
        XCTAssertTrue(store.intervalMode)

        store.setShooting(ShootingDuration(days: 0, hours: 4, minutes: 10, seconds: 0))
        XCTAssertEqual(store.interval, 10)

        store.setPlayback(PlaybackDuration(hours: 0, minutes: 0, seconds: 50, frames: 0))
        XCTAssertEqual(store.shots, 1500)
        XCTAssertEqual(store.interval, 10)
    }

    func testResetRestoresSavedDefaults() {
        let store = makeStore()
        store.saveDefaults(SavedDefaults(interval: 10, shots: 1500, fps: 30, intervalMode: true))
        store.setInterval(60)
        store.setShots(120)
        store.setFPS(25)
        store.reset()
        XCTAssertEqual(store.interval, 10)
        XCTAssertEqual(store.shots, 1500)
        XCTAssertEqual(store.fps, 30)
        XCTAssertTrue(store.intervalMode)
        XCTAssertEqual(store.shooting, Calculator.shootingDuration(shots: 1500, interval: 10))
        XCTAssertEqual(store.playback, Calculator.playbackDuration(shots: 1500, fps: 30))
    }

    func testSaveDefaultsAppliesImmediately() {
        let store = makeStore()
        store.setInterval(60)
        store.setShots(120)
        store.setFPS(25)
        store.saveDefaults(SavedDefaults(interval: 10, shots: 1500, fps: 30, intervalMode: true))
        XCTAssertEqual(store.interval, 10)
        XCTAssertEqual(store.shots, 1500)
        XCTAssertEqual(store.fps, 30)
        XCTAssertTrue(store.intervalMode)
        XCTAssertEqual(store.shooting, Calculator.shootingDuration(shots: 1500, interval: 10))
    }

    func testIntervalModePersistsAcrossLaunch() {
        let suite = "com.sighmon.timelapse.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)

        let first = CalculatorStore(defaults: defaults)
        XCTAssertFalse(first.intervalMode)
        first.toggleIntervalMode()
        XCTAssertTrue(first.intervalMode)
        XCTAssertTrue(defaults.bool(forKey: CalculatorStore.Keys.intervalToggle))

        let second = CalculatorStore(defaults: defaults)
        XCTAssertTrue(second.intervalMode)
        second.toggleIntervalMode()
        XCTAssertFalse(second.intervalMode)

        let third = CalculatorStore(defaults: defaults)
        XCTAssertFalse(third.intervalMode)
    }

    private func makeStore() -> CalculatorStore {
        let suite = "com.sighmon.timelapse.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return CalculatorStore(defaults: defaults)
    }
}
