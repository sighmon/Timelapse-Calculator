//
//  TimelapseApp.swift
//  Timelapse
//

import SwiftUI

@main
struct TimelapseApp: App {
    var body: some Scene {
        WindowGroup {
            CalculatorView()
        }
    }
}

// Keep the modern appearance while supporting the material system on iOS 17–18.
extension View {
    @ViewBuilder
    func adaptiveGlass<S: Shape>(
        in shape: S,
        tint: Color? = nil,
        interactive: Bool = true,
        enabled: Bool = true
    ) -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(
                enabled ? .regular.tint(tint).interactive(interactive) : .identity,
                in: shape
            )
        } else if enabled {
            background(.regularMaterial, in: shape)
                .background {
                    if let tint {
                        shape.fill(tint)
                    }
                }
                .overlay {
                    shape.stroke(.white.opacity(0.15), lineWidth: 0.5)
                        .allowsHitTesting(false)
                }
        } else {
            self
        }
    }

    @ViewBuilder
    func adaptiveProminentButtonStyle() -> some View {
        if #available(iOS 26.0, *) {
            buttonStyle(.glassProminent)
        } else {
            buttonStyle(.borderedProminent)
        }
    }
}

struct AdaptiveGlassContainer<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder var content: () -> Content

    var body: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: spacing, content: content)
        } else {
            content()
        }
    }
}
