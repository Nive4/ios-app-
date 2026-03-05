import SwiftUI
import Combine

struct LandingPageView: View {
    var onStart: () -> Void // Callback for navigation
    
    @State private var moonScale: CGFloat = 1.0
    @State private var moonGlowOpacity: Double = 0.5
    @State private var titleOpacity: Double = 0.0
    @State private var flashOpacity: Double = 0.0
    @State private var buttonScale: CGFloat = 1.0
    @State private var underlineWidth: CGFloat = 0
    @State private var titleShimmer: CGFloat = -1
    
    // Mech Animation
    @State private var mechOffsetY: CGFloat = 0.0
    @State private var mechScale: CGFloat = 1.0
    
    // Cloud Animation
    @State private var cloudOffset1: CGFloat = -200
    @State private var cloudOffset2: CGFloat = -200
    @State private var cloudOffset3: CGFloat = -200
    
    // Lumina Particles
    @State private var particles: [LuminaParticle] = []
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // MARK: - 1. Deep Space Background
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.05, green: 0.0, blue: 0.15), // Deep Purple
                Color(red: 0.0, green: 0.0, blue: 0.1),  // Midnight Blue
                Color.black
            ]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            
            // MARK: - 2. Starry Night
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<100, id: \.self) { _ in
                        StarView()
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height * 0.6)
                            )
                    }
                }
            }
            
            // MARK: - Shooting Stars
            ShootingStar(delay: 2, duration: 0.6, startX: 0.7, startY: 0.05, color: .white)
            ShootingStar(delay: 7, duration: 0.5, startX: 0.3, startY: 0.12, color: .cyan)
            ShootingStar(delay: 12, duration: 0.7, startX: 0.5, startY: 0.02, color: .white)
            
            // MARK: - 3. Full Moon (Smaller, Left)
            GeometryReader { geometry in
                ZStack {
                    // Pulsing Halo Rings
                    PulsingRing(color: .white.opacity(0.15), maxRadius: RS.v(140), duration: 3.0)
                    PulsingRing(color: .cyan.opacity(0.1), maxRadius: RS.v(120), duration: 4.0)
                    
                    // Outer Glow
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.2),
                                    Color(red: 0.8, green: 0.9, blue: 1.0).opacity(0.08),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: RS.v(30),
                                endRadius: RS.v(80)
                            )
                        )
                        .frame(width: RS.v(160), height: RS.v(160))
                        .scaleEffect(moonScale)
                        .opacity(moonGlowOpacity)
                    
                    // Inner Glow
                    Circle()
                        .fill(Color(red: 1.0, green: 1.0, blue: 0.8).opacity(0.4))
                        .frame(width: RS.v(80), height: RS.v(80))
                    
                    // The Moon
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 1.0, blue: 0.95),
                                    Color(red: 0.95, green: 0.93, blue: 0.85)
                                ]),
                                center: UnitPoint(x: 0.4, y: 0.4),
                                startRadius: 0,
                                endRadius: RS.v(35)
                            )
                        )
                        .frame(width: RS.v(70), height: RS.v(70))
                        .shadow(color: .white.opacity(0.9), radius: RS.v(20), x: 0, y: 0)
                }
                .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.15) // Top Left
                .onAppear {
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        moonScale = 1.15
                        moonGlowOpacity = 0.9
                    }
                }
            }
            
            // MARK: - 4. Pixel Clouds (Looping within screen)
            GeometryReader { geometry in
                ZStack {
                    PixelCloudView()
                        .position(x: cloudOffset1, y: geometry.size.height * 0.2)
                    PixelCloudView()
                        .scaleEffect(0.8)
                        .position(x: cloudOffset2, y: geometry.size.height * 0.3)
                    PixelCloudView()
                        .scaleEffect(1.2)
                        .position(x: cloudOffset3, y: geometry.size.height * 0.25)
                }
                .onAppear {
                    let width = geometry.size.width
                    // Animate clouds back and forth for screen containment
                    cloudOffset1 = width * 0.2
                    cloudOffset2 = width * 0.8
                    cloudOffset3 = width * 0.5
                    
                    withAnimation(.easeInOut(duration: 15).repeatForever(autoreverses: true)) {
                        cloudOffset1 = width * 0.8
                    }
                    withAnimation(.easeInOut(duration: 20).repeatForever(autoreverses: true)) {
                        cloudOffset2 = width * 0.2
                    }
                     withAnimation(.easeInOut(duration: 25).repeatForever(autoreverses: true)) {
                        cloudOffset3 = width * 0.9
                    }
                }
            }
            
            // MARK: - Aurora Borealis (behind mountains)
            AuroraView()
            
            // MARK: - 5. Background Mountains (Parallax Layer 1)
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    ZStack {
                        // Mountain glow edge
                        MountainShape()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.purple.opacity(0.2),
                                        Color.cyan.opacity(0.1),
                                        Color.purple.opacity(0.2)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 2
                            )
                            .frame(height: RS.v(200))
                            .blur(radius: 3)
                        
                        MountainShape()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.08, green: 0.06, blue: 0.18),
                                        Color(red: 0.12, green: 0.1, blue: 0.22)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: RS.v(200))
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            
            // MARK: - 6. Lumina Particles (Floating Up)
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .position(x: particle.x, y: particle.y)
                    .blur(radius: particle.size > 4 ? 1 : 0)
            }
            
            // MARK: - 7. Village Silhouettes (Foreground)
            VStack {
                Spacer()
                HStack(alignment: .bottom, spacing: RS.v(2)) {
                    ForEach(0..<(RS.isIPad ? 20 : 12), id: \.self) { index in
                        BuildingView(
                            width: CGFloat.random(in: RS.v(30)...RS.v(70)),
                            height: CGFloat.random(in: RS.v(80)...RS.v(200))
                        )
                    }
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            
            // MARK: - 8. LuminaMech Image (Larger & Centered)
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    Image("LuminaMech") // Ensure this image is in Assets.xcassets
                        .resizable()
                        .scaledToFit()
                        .frame(height: RS.v(280)) // Scales for iPad
                        .scaleEffect(mechScale)
                        .offset(y: mechOffsetY)
                        .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.55) // Centered
                        .onAppear {
                            // Float animation
                            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                                mechOffsetY = RS.v(-20)
                            }
                            // Breathing animation
                            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                                mechScale = 1.05
                            }
                        }
                }
            }
            
            // MARK: - 9. Foreground Ground
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.black)
                    .frame(height: RS.v(20))
            }
            .edgesIgnoringSafeArea(.bottom)
            
            // MARK: - 10. Title & UI
            VStack {
                Spacer()
                
                // Title Group
                VStack(spacing: RS.v(8)) {
                    ZStack {
                        // Glow layer behind text
                        Text("THE LAST CIRCUIT")
                            .font(.custom("CourierNew-Bold", size: RS.font(38)))
                            .foregroundColor(.cyan.opacity(0.3))
                            .blur(radius: RS.v(10))
                        
                        Text("THE LAST CIRCUIT")
                            .font(.custom("CourierNew-Bold", size: RS.font(38)))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white,
                                        Color(red: 0.7, green: 0.9, blue: 1.0),
                                        .white
                                    ]),
                                    startPoint: UnitPoint(x: titleShimmer, y: 0),
                                    endPoint: UnitPoint(x: titleShimmer + 0.3, y: 1)
                                )
                            )
                            .shadow(color: .cyan, radius: RS.v(12))
                            .shadow(color: .purple.opacity(0.5), radius: RS.v(5))
                    }
                    .opacity(titleOpacity)
                    
                    // Animated underline
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.cyan.opacity(0), .cyan, .purple, .cyan.opacity(0)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: underlineWidth, height: RS.v(2))
                        .opacity(titleOpacity)
                    
                    Text("\"Illuminating the path to glory.\"")
                        .font(.custom("CourierNew", size: RS.font(14)))
                        .foregroundColor(.gray)
                        .opacity(titleOpacity)
                }
                .padding(.bottom, RS.v(40))
                
                // Button
                Button(action: {
                    onStart()
                }) {
                    Text("INITIALIZE")
                        .font(.system(size: RS.font(24), weight: .bold, design: .monospaced))
                        .foregroundColor(.yellow)
                        .padding(.horizontal, RS.v(50))
                        .padding(.vertical, RS.v(15))
                        .background(
                            ZStack {
                                Color.black.opacity(0.8)
                                RoundedRectangle(cornerRadius: RS.v(8))
                                    .stroke(
                                        LinearGradient(gradient: Gradient(colors: [.yellow, .orange]), startPoint: .leading, endPoint: .trailing),
                                        lineWidth: RS.v(3)
                                    )
                            }
                        )
                        .shadow(color: .yellow.opacity(0.5), radius: RS.v(10), x: 0, y: 0)
                        .scaleEffect(buttonScale)
                }
                .opacity(titleOpacity)
                .padding(.bottom, RS.v(60))
            }
            .onAppear {
                // Intro Animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeIn(duration: 0.1)) {
                        flashOpacity = 1.0
                    }
                    withAnimation(.easeOut(duration: 1.0).delay(0.1)) {
                        flashOpacity = 0.0
                        titleOpacity = 1.0
                    }
                    // Animated underline reveal
                    withAnimation(.easeOut(duration: 1.2).delay(0.5)) {
                        underlineWidth = RS.v(280)
                    }
                    // Title shimmer loop
                    withAnimation(.linear(duration: 3).repeatForever(autoreverses: false).delay(1.0)) {
                        titleShimmer = 2
                    }
                }
                // Button Pulse
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    buttonScale = 1.05
                }
            }
            
            // MARK: - 11. Screen Flash
            Color.white
                .opacity(flashOpacity)
                .edgesIgnoringSafeArea(.all)
                .allowsHitTesting(false)
        }
        .onReceive(timer) { _ in
            updateParticles()
        }
    }
    
    // Logic to spawn and move particles
    func updateParticles() {
        // Move existing
        for i in particles.indices {
            particles[i].y -= particles[i].speed
            particles[i].opacity -= 0.005
        }
        // Remove dead
        particles.removeAll { $0.y < 0 || $0.opacity <= 0 }
        
        // Spawn new
        if Double.random(in: 0...1) < 0.35 { // 35% chance per tick
            let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds ?? CGRect(x: 0, y: 0, width: 400, height: 900)
            let screenWidth = screenBounds.width
            let screenHeight = screenBounds.height
            let particleColor: Color = [
                .cyan, .cyan, .cyan,
                Color(red: 0.7, green: 0.5, blue: 1.0),  // Purple
                Color(red: 1.0, green: 0.85, blue: 0.4)   // Gold
            ].randomElement()!
            let newParticle = LuminaParticle(
                id: UUID(),
                x: CGFloat.random(in: 0...screenWidth),
                y: screenHeight,
                size: CGFloat.random(in: 2...7),
                speed: CGFloat.random(in: 1...3),
                opacity: Double.random(in: 0.5...1.0),
                color: particleColor
            )
            particles.append(newParticle)
        }
    }
}

// MARK: - Models

struct LuminaParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let speed: CGFloat
    var opacity: Double
    var color: Color = .cyan
}

// MARK: - Subviews

struct PixelCloudView: View {
    var body: some View {
        ZStack {
            // Main body
            Rectangle().fill(Color.white.opacity(0.1)).frame(width: RS.v(100), height: RS.v(30))
            // Top bump
            Rectangle().fill(Color.white.opacity(0.1)).frame(width: RS.v(60), height: RS.v(20)).offset(y: RS.v(-20))
            // Side bumps
            Rectangle().fill(Color.white.opacity(0.1)).frame(width: RS.v(30), height: RS.v(20)).offset(x: RS.v(-40), y: RS.v(10))
            Rectangle().fill(Color.white.opacity(0.1)).frame(width: RS.v(40), height: RS.v(25)).offset(x: RS.v(35), y: RS.v(5))
        }
    }
}

struct StarView: View {
    @State private var opacity: Double = Double.random(in: 0.3...1.0)
    
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: RS.v(2), height: RS.v(2))
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: Double.random(in: 1...3)).repeatForever(autoreverses: true)) {
                    opacity = Double.random(in: 0.1...0.5)
                }
            }
    }
}

struct MountainShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height * 0.7))
        path.addLine(to: CGPoint(x: rect.width * 0.2, y: rect.height * 0.4)) // Peak 1
        path.addLine(to: CGPoint(x: rect.width * 0.4, y: rect.height * 0.6)) // Valley 1
        path.addLine(to: CGPoint(x: rect.width * 0.6, y: rect.height * 0.3)) // Peak 2
        path.addLine(to: CGPoint(x: rect.width * 0.8, y: rect.height * 0.5)) // Valley 2
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.8))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}

struct BuildingView: View {
    let width: CGFloat
    let height: CGFloat
    
    // Grid of windows
    let rows: Int = Int.random(in: 4...10)
    let cols: Int = Int.random(in: 2...4)
    let hasAntenna: Bool = Bool.random()
    let hasSatellite: Bool = Bool.random()
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                // Rooftop details
                if hasAntenna {
                    Rectangle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: RS.v(1.5), height: RS.v(15))
                        .overlay(
                            Circle()
                                .fill(Color.red.opacity(0.8))
                                .frame(width: RS.v(3), height: RS.v(3))
                                .offset(y: -RS.v(7))
                        )
                } else if hasSatellite {
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.white.opacity(0.12))
                            .frame(width: RS.v(1), height: RS.v(8))
                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: RS.v(8), height: RS.v(1.5))
                            .offset(y: -RS.v(4))
                    }
                }
                
                ZStack(alignment: .bottom) {
                    // Building Shape
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.05, green: 0.03, blue: 0.08),
                                    Color.black
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: width, height: height)
                        .overlay(
                            Rectangle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.12),
                                            Color.white.opacity(0.04)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: RS.v(0.5)
                                )
                        )
                    
                    // Windows
                    VStack(spacing: RS.v(4)) {
                        ForEach(0..<rows, id: \.self) { _ in
                            HStack(spacing: RS.v(4)) {
                                ForEach(0..<cols, id: \.self) { _ in
                                    WindowView()
                                }
                            }
                        }
                        Spacer().frame(height: RS.v(5))
                    }
                    .padding(.bottom, RS.v(2))
                }
            }
        }
    }
}

struct WindowView: View {
    @State private var opacity: Double = 0.2
    let color: Color = [Color.yellow, Color.orange, Color.cyan].randomElement()!
    
    var body: some View {
        Rectangle()
            .fill(color.opacity(opacity))
            .frame(width: RS.v(6), height: RS.v(8))
            .onAppear {
                // Random start delay to desynchronize
                let delay = Double.random(in: 0.0...5.0)
                let duration = Double.random(in: 0.2...2.0)
                
                withAnimation(
                    Animation.easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                ) {
                    opacity = Double.random(in: 0.8...1.0)
                }
            }
    }
}

#Preview {
    LandingPageView(onStart: {})
}
