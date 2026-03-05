import SwiftUI

// MARK: - Shooting Star

struct ShootingStar: View {
    let delay: Double
    let duration: Double
    let startX: CGFloat
    let startY: CGFloat
    let color: Color
    
    @State private var progress: CGFloat = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        GeometryReader { geo in
            let length: CGFloat = RS.v(80)
            let angle: CGFloat = .pi / 5 // ~36 degrees
            
            Capsule()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0),
                            color.opacity(0.8 * opacity),
                            .white.opacity(opacity)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: length, height: RS.v(2))
                .rotationEffect(.radians(angle))
                .position(
                    x: startX * geo.size.width + progress * geo.size.width * 0.4,
                    y: startY * geo.size.height + progress * geo.size.height * 0.3
                )
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                        shootStar()
                    }
                }
        }
        .allowsHitTesting(false)
    }
    
    private func shootStar() {
        progress = 0
        opacity = 0
        
        withAnimation(.easeIn(duration: 0.15)) {
            opacity = 1.0
        }
        withAnimation(.easeIn(duration: duration)) {
            progress = 1.0
        }
        withAnimation(.easeOut(duration: 0.3).delay(duration * 0.7)) {
            opacity = 0
        }
        
        // Loop
        Timer.scheduledTimer(withTimeInterval: duration + Double.random(in: 3...8), repeats: false) { _ in
            shootStar()
        }
    }
}

// MARK: - Aurora Borealis

struct AuroraView: View {
    @State private var phase: CGFloat = 0
    @State private var intensity: Double = 0.3
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Layer 1: Green/Teal band
                auroraWave(
                    geo: geo,
                    colors: [
                        Color(red: 0.0, green: 0.8, blue: 0.4).opacity(0.08),
                        Color(red: 0.0, green: 0.6, blue: 0.8).opacity(0.05),
                        Color.clear
                    ],
                    yOffset: geo.size.height * 0.35,
                    waveHeight: RS.v(60),
                    phaseOffset: 0
                )
                
                // Layer 2: Purple/Pink band
                auroraWave(
                    geo: geo,
                    colors: [
                        Color(red: 0.5, green: 0.2, blue: 0.8).opacity(0.06),
                        Color(red: 0.8, green: 0.3, blue: 0.6).opacity(0.04),
                        Color.clear
                    ],
                    yOffset: geo.size.height * 0.3,
                    waveHeight: RS.v(50),
                    phaseOffset: .pi / 3
                )
            }
            .opacity(intensity)
            .blur(radius: RS.v(15))
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                phase = .pi * 2
                intensity = 0.7
            }
        }
        .allowsHitTesting(false)
    }
    
    func auroraWave(geo: GeometryProxy, colors: [Color], yOffset: CGFloat, waveHeight: CGFloat, phaseOffset: CGFloat) -> some View {
        Path { path in
            let width = geo.size.width
            path.move(to: CGPoint(x: 0, y: yOffset))
            for x in stride(from: 0, through: width, by: 2) {
                let relX = x / width
                let y = yOffset + sin(relX * .pi * 3 + phase + phaseOffset) * waveHeight
                path.addLine(to: CGPoint(x: x, y: y))
            }
            path.addLine(to: CGPoint(x: geo.size.width, y: yOffset + waveHeight * 2))
            path.addLine(to: CGPoint(x: 0, y: yOffset + waveHeight * 2))
            path.closeSubpath()
        }
        .fill(
            LinearGradient(
                gradient: Gradient(colors: colors),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - CRT Scanline Overlay

struct CRTOverlay: View {
    let lineSpacing: CGFloat
    let opacity: Double
    
    init(lineSpacing: CGFloat = 3, opacity: Double = 0.06) {
        self.lineSpacing = lineSpacing
        self.opacity = opacity
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: lineSpacing) {
                ForEach(0..<Int(geo.size.height / (lineSpacing + 1)), id: \.self) { _ in
                    Rectangle()
                        .fill(Color.black.opacity(opacity))
                        .frame(height: 1)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Holographic Shimmer Border

struct HolographicBorder: View {
    let cornerRadius: CGFloat
    let width: CGFloat
    let height: CGFloat
    
    @State private var shimmerOffset: CGFloat = -1
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [
                        .cyan.opacity(0.6),
                        .purple.opacity(0.4),
                        .pink.opacity(0.3),
                        .yellow.opacity(0.3),
                        .green.opacity(0.4),
                        .cyan.opacity(0.6)
                    ]),
                    center: .center,
                    startAngle: .degrees(Double(shimmerOffset) * 360.0),
                    endAngle: .degrees(Double(shimmerOffset) * 360.0 + 360.0)
                ),
                lineWidth: RS.v(2.5)
            )
            .frame(width: width, height: height)
            .onAppear {
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    shimmerOffset = 1
                }
            }
    }
}

// MARK: - Particle Burst (Success Celebration)

struct ParticleBurstView: View {
    let color: Color
    let particleCount: Int
    
    @State private var particles: [BurstParticle] = []
    @State private var isActive = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                        .blur(radius: particle.size > 4 ? 1 : 0)
                }
            }
            .onAppear {
                spawnBurst(in: geo.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    func spawnBurst(in size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        
        for _ in 0..<particleCount {
            let angle = Double.random(in: 0...(.pi * 2))
            let distance = CGFloat.random(in: 50...200)
            let particleColor = [color, .white, color.opacity(0.6)].randomElement()!
            
            let particle = BurstParticle(
                id: UUID(),
                x: centerX,
                y: centerY,
                targetX: centerX + cos(angle) * distance,
                targetY: centerY + sin(angle) * distance,
                size: CGFloat.random(in: 2...6),
                color: particleColor,
                opacity: 1.0
            )
            particles.append(particle)
        }
        
        // Animate outward
        withAnimation(.easeOut(duration: 0.8)) {
            for i in particles.indices {
                particles[i].x = particles[i].targetX
                particles[i].y = particles[i].targetY
            }
        }
        
        // Fade out
        withAnimation(.easeOut(duration: 1.2).delay(0.4)) {
            for i in particles.indices {
                particles[i].opacity = 0
            }
        }
    }
}

struct BurstParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var targetX: CGFloat
    var targetY: CGFloat
    var size: CGFloat
    var color: Color
    var opacity: Double
}

// MARK: - Electric Arc

struct ElectricArc: Shape {
    var segments: Int
    var amplitude: CGFloat
    
    var animatableData: CGFloat {
        get { amplitude }
        set { amplitude = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let segmentWidth = rect.width / CGFloat(segments)
        
        path.move(to: CGPoint(x: 0, y: rect.midY))
        
        for i in 1...segments {
            let x = segmentWidth * CGFloat(i)
            let y = rect.midY + CGFloat.random(in: -amplitude...amplitude)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
}

// MARK: - Animated Light Beam

struct LightBeam: View {
    let color: Color
    let width: CGFloat
    let delay: Double
    
    @State private var opacity: Double = 0
    @State private var height: CGFloat = 0
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        color.opacity(0),
                        color.opacity(0.15 * opacity),
                        color.opacity(0.05 * opacity),
                        color.opacity(0)
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .frame(width: width)
            .blur(radius: RS.v(5))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeOut(duration: 2.0)) {
                        opacity = 1.0
                    }
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        opacity = 0.6
                    }
                }
            }
    }
}

// MARK: - Typing Text Effect

struct TypingText: View {
    let fullText: String
    let font: Font
    let color: Color
    let typingSpeed: Double
    
    @State private var displayedText: String = ""
    @State private var charIndex: Int = 0
    
    var body: some View {
        Text(displayedText + (charIndex < fullText.count ? "▌" : ""))
            .font(font)
            .foregroundColor(color)
            .onAppear {
                startTyping()
            }
    }
    
    func startTyping() {
        Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { timer in
            if charIndex < fullText.count {
                let idx = fullText.index(fullText.startIndex, offsetBy: charIndex)
                displayedText += String(fullText[idx])
                charIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
}

// MARK: - Confetti View

struct ConfettiView: View {
    let colors: [Color]
    let count: Int
    
    @State private var confetti: [ConfettiPiece] = []
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(confetti) { piece in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(piece.color)
                        .frame(width: piece.width, height: piece.height)
                        .rotationEffect(.degrees(piece.rotation))
                        .position(x: piece.x, y: piece.y)
                        .opacity(piece.opacity)
                }
            }
            .onAppear {
                spawnConfetti(in: geo.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    func spawnConfetti(in size: CGSize) {
        for _ in 0..<count {
            let piece = ConfettiPiece(
                id: UUID(),
                x: CGFloat.random(in: 0...size.width),
                y: -20,
                width: CGFloat.random(in: 3...8),
                height: CGFloat.random(in: 6...14),
                color: colors.randomElement()!,
                rotation: Double.random(in: 0...360),
                opacity: 1.0
            )
            confetti.append(piece)
        }
        
        // Animate falling
        withAnimation(.easeIn(duration: Double.random(in: 2...4))) {
            for i in confetti.indices {
                confetti[i].y = size.height + 50
                confetti[i].x += CGFloat.random(in: -60...60)
                confetti[i].rotation += Double.random(in: 180...720)
            }
        }
        
        withAnimation(.easeIn(duration: 3).delay(1.5)) {
            for i in confetti.indices {
                confetti[i].opacity = 0
            }
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    var color: Color
    var rotation: Double
    var opacity: Double
}

// MARK: - Pulsing Ring

struct PulsingRing: View {
    let color: Color
    let maxRadius: CGFloat
    let duration: Double
    
    @State private var scale: CGFloat = 0.5
    @State private var ringOpacity: Double = 0.6
    
    var body: some View {
        Circle()
            .stroke(color, lineWidth: RS.v(1.5))
            .frame(width: maxRadius, height: maxRadius)
            .scaleEffect(scale)
            .opacity(ringOpacity)
            .onAppear {
                withAnimation(.easeOut(duration: duration).repeatForever(autoreverses: false)) {
                    scale = 1.5
                    ringOpacity = 0
                }
            }
    }
}
