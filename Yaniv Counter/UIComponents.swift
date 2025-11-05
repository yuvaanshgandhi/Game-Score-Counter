//
//  UIComponents.swift
//  Yaniv Counter
//
//  Created by Yuvaansh Gandhi on 2025-11-02.
//

import SwiftUI

// MARK: - Liquid Glass Background Effect

struct LiquidGlassBackground: View {
    var color: Color = .orange.opacity(0.15)
    var intensity: Double = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base gradient
                LinearGradient(
                    colors: [
                        color.opacity(0.3 * intensity),
                        color.opacity(0.1 * intensity),
                        color.opacity(0.05 * intensity)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Animated blob
                BlobShape()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(0.4 * intensity),
                                color.opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .offset(x: geometry.size.width * 0.7, y: -100)
                    .blur(radius: 40)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Animated Blob Shape

struct BlobShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.3))
        
        path.addCurve(
            to: CGPoint(x: width * 0.8, y: height * 0.5),
            control1: CGPoint(x: width * 0.7, y: height * 0.3),
            control2: CGPoint(x: width * 0.8, y: height * 0.4)
        )
        
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.8),
            control1: CGPoint(x: width * 0.8, y: height * 0.6),
            control2: CGPoint(x: width * 0.7, y: height * 0.8)
        )
        
        path.addCurve(
            to: CGPoint(x: width * 0.2, y: height * 0.5),
            control1: CGPoint(x: width * 0.3, y: height * 0.8),
            control2: CGPoint(x: width * 0.2, y: height * 0.6)
        )
        
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.3),
            control1: CGPoint(x: width * 0.2, y: height * 0.4),
            control2: CGPoint(x: width * 0.3, y: height * 0.3)
        )
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Progress Bar

struct ProgressBar: View {
    let progress: Double // 0.0 to 1.0
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.2))
                    .frame(height: 8)
                
                // Progress
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * min(progress, 1.0), height: 8)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
            }
        }
        .frame(height: 8)
    }
}

// MARK: - Confetti Effect

struct ConfettiView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { index in
                Circle()
                    .fill([Color.red, .blue, .green, .yellow, .purple, .orange].randomElement() ?? .blue)
                    .frame(width: CGFloat.random(in: 4...8), height: CGFloat.random(in: 4...8))
                    .offset(
                        x: isAnimating ? CGFloat.random(in: -200...200) : 0,
                        y: isAnimating ? CGFloat.random(in: -300...300) : 0
                    )
                    .opacity(isAnimating ? 0 : 1)
                    .animation(
                        Animation.easeOut(duration: Double.random(in: 1...3))
                            .delay(Double.random(in: 0...0.5)),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

