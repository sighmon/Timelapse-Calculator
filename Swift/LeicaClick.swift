//
//  LeicaClick.swift
//  Timelapse
//
//  Mechanical sounds + matching haptics: sharp detent ticks on the wheels,
//  and a ker–thunk shutter for interval mode.
//

import AVFoundation
import CoreHaptics
import UIKit

enum LeicaClick {
    enum Kind {
        case detent
        case shutter
    }

    private static let selectionHaptic = UISelectionFeedbackGenerator()
    private static let detentImpact = UIImpactFeedbackGenerator(style: .rigid)
    private static let shutterKerImpact = UIImpactFeedbackGenerator(style: .medium)
    private static let shutterThunkImpact = UIImpactFeedbackGenerator(style: .heavy)
    private static var engine: CHHapticEngine?
    private static var supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    private static var players: [Kind: [AVAudioPlayer]] = [:]
    private static var nextPlayer: [Kind: Int] = [:]
    private static var lastPlay: [Kind: TimeInterval] = [:]
    private static var didPrepare = false

    static func prepare() {
        guard !didPrepare else { return }
        didPrepare = true
        selectionHaptic.prepare()
        detentImpact.prepare()
        shutterKerImpact.prepare()
        shutterThunkImpact.prepare()
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        load(.detent, resource: "leica-click", volume: 0.42)
        load(.shutter, resource: "leica-shutter", volume: 0.7)
    }

    static func play() {
        play(.detent)
    }

    static func playShutter() {
        play(.shutter)
    }

    private static func play(_ kind: Kind) {
        prepare()
        let now = CACurrentMediaTime()
        let minGap: TimeInterval = kind == .shutter ? 0.16 : 0.024
        if let previous = lastPlay[kind], now - previous < minGap {
            return
        }
        lastPlay[kind] = now
        playHaptic(kind)
        guard let pool = players[kind], !pool.isEmpty else { return }
        let index = nextPlayer[kind, default: 0] % pool.count
        nextPlayer[kind] = index + 1
        let player = pool[index]
        player.currentTime = 0
        player.play()
    }

    private static func playHaptic(_ kind: Kind) {
        prepareHapticEngine()
        if supportsHaptics, let engine {
            do {
                try engine.start()
                let pattern = try hapticPattern(for: kind)
                let player = try engine.makePlayer(with: pattern)
                try player.start(atTime: CHHapticTimeImmediate)
                return
            } catch {
            }
        }
        switch kind {
        case .detent:
            selectionHaptic.selectionChanged()
            detentImpact.impactOccurred(intensity: 0.45)
            selectionHaptic.prepare()
            detentImpact.prepare()
        case .shutter:
            shutterKerImpact.impactOccurred(intensity: 0.7)
            shutterKerImpact.prepare()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                shutterThunkImpact.impactOccurred(intensity: 1.0)
                shutterThunkImpact.prepare()
            }
        }
    }

    private static func hapticPattern(for kind: Kind) throws -> CHHapticPattern {
        switch kind {
        case .detent:
            return try CHHapticPattern(events: [
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.62),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.98)
                    ],
                    relativeTime: 0
                )
            ], parameters: [])
        case .shutter:
            return try CHHapticPattern(events: [
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.72),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.85)
                    ],
                    relativeTime: 0
                ),
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.12)
                    ],
                    relativeTime: 0.04
                ),
                CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.55),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.08)
                    ],
                    relativeTime: 0.04,
                    duration: 0.07
                )
            ], parameters: [])
        }
    }

    private static func prepareHapticEngine() {
        guard supportsHaptics, engine == nil else { return }
        do {
            let hapticEngine = try CHHapticEngine()
            hapticEngine.isAutoShutdownEnabled = true
            engine = hapticEngine
        } catch {
            engine = nil
        }
    }

    private static func load(_ kind: Kind, resource: String, volume: Float) {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "wav") else { return }
        players[kind] = (0..<3).compactMap { _ in
            let player = try? AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.volume = volume
            return player
        }
    }
}
