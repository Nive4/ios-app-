import SwiftUI
import Combine

struct GloryView: View {
    // Animation States
    @State private var imageOpacity: Double = 0.0
    @State private var imageScale: CGFloat = 1.1

    @State private var titleOpacity: Double = 0.0
    @State private var messageOpacity: Double = 0.0
    @State private var lessonOpacity: Double = 0.0
    @State private var creditsOpacity: Double = 0.0
    @State private var glowPulse: Double = 0.5
    @State private var starAlpha: Double = 0.3
    @State private var showConfetti: Bool = false
    @State private var titleGlowPhase: CGFloat = 0
    
    // Firefly particles
    @State private var fireflies: [GloryParticle] = []
    let fireflyTimer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // MARK: - Background
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.01, green: 0.02, blue: 0.06),
                Color(red: 0.02, green: 0.04, blue: 0.10),
                Color(red: 0.04, green: 0.06, blue: 0.14),
                Color(red: 0.02, green: 0.03, blue: 0.08)
            ]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            
            // MARK: - Stars
            GeometryReader { geometry in
                ForEach(0..<70, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.1...0.5) * starAlpha))
                        .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat(i * 29 % Int(geometry.size.width)),
                            y: CGFloat.random(in: 0...geometry.size.height * 0.4)
                        )
                }
            }
            
            // MARK: - Light Beams (behind city)
            GeometryReader { geo in
                HStack(spacing: geo.size.width / 6) {
                    LightBeam(color: Color(red: 1.0, green: 0.85, blue: 0.4), width: RS.v(25), delay: 0.5)
                    LightBeam(color: Color(red: 0.6, green: 0.8, blue: 1.0), width: RS.v(18), delay: 1.2)
                    LightBeam(color: Color(red: 1.0, green: 0.85, blue: 0.4), width: RS.v(22), delay: 0.8)
                    LightBeam(color: Color(red: 0.6, green: 0.8, blue: 1.0), width: RS.v(20), delay: 1.5)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // MARK: - Firefly Particles
            ForEach(fireflies) { particle in
                Circle()
                    .fill(particle.color.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .position(x: particle.x, y: particle.y)
                    .blur(radius: particle.size > 3.5 ? 2 : 1)
            }
            
            // CRT overlay for visual consistency
            CRTOverlay(lineSpacing: 5, opacity: 0.02)
                .edgesIgnoringSafeArea(.all)
            
            // Confetti celebration
            if showConfetti {
                ConfettiView(
                    colors: [
                        Color(red: 1.0, green: 0.85, blue: 0.4),
                        .cyan,
                        .purple,
                        .white,
                        Color(red: 0.6, green: 0.8, blue: 1.0)
                    ],
                    count: 40
                )
            }
            
            // MARK: - Main Content (Scrollable)
            GeometryReader { geo in
                let w = geo.size.width
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 20)
                        
                        // MARK: - Glory Image (Floating Island City)
                        ZStack {
                            Image("GloryCity2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: w * 0.85)
                                .blur(radius: RS.v(30))
                                .opacity(0.4 * glowPulse)
                                .blendMode(.screen)
                            
                            Image("GloryCity2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: w * 0.85)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.5 * glowPulse),
                                                    Color(red: 0.9, green: 0.7, blue: 0.3).opacity(0.2),
                                                    Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.5 * glowPulse)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .shadow(color: Color(red: 1.0, green: 0.8, blue: 0.3).opacity(0.3), radius: RS.v(20))
                        }
                        .scaleEffect(imageScale)
                        .opacity(imageOpacity)
                        
                        Spacer().frame(height: 24)
                        
                        // MARK: - Title
                        VStack(spacing: 6) {
                            ZStack {
                                // Glow behind title
                                Text("⚡ GLORY RESTORED ⚡")
                                    .font(.system(size: RS.font(20), weight: .bold, design: .monospaced))
                                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.4))
                                    .blur(radius: RS.v(8))
                                
                                Text("⚡ GLORY RESTORED ⚡")
                                    .font(.system(size: RS.font(20), weight: .bold, design: .monospaced))
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 1.0, green: 0.85, blue: 0.4),
                                                Color(red: 1.0, green: 0.95, blue: 0.7),
                                                Color(red: 1.0, green: 0.85, blue: 0.4)
                                            ]),
                                            startPoint: UnitPoint(x: titleGlowPhase, y: 0),
                                            endPoint: UnitPoint(x: titleGlowPhase + 0.5, y: 1)
                                        )
                                    )
                                    .shadow(color: Color(red: 1.0, green: 0.8, blue: 0.3).opacity(0.6), radius: RS.v(10))
                            }
                            
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.clear,
                                            Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.5),
                                            Color.clear
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 220, height: 1)
                        }
                        .opacity(titleOpacity)
                        
                        Spacer().frame(height: 18)
                        
                        // MARK: - Message
                        VStack(spacing: 10) {
                            Text("You have restored the glory\nof the city.")
                                .font(.system(size: RS.font(16), weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.95))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                            
                            Text("Every light that flickers, every\ncircuit that hums — it was you.")
                                .font(.system(size: RS.font(13), weight: .regular, design: .monospaced))
                                .foregroundColor(.white.opacity(0.65))
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)
                            
                            Text("The Last Circuit is complete.")
                                .font(.system(size: RS.font(13), weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.6, green: 0.8, blue: 1.0))
                        }
                        .padding(.horizontal, RS.v(30))
                        .opacity(messageOpacity)
                        
                        Spacer().frame(height: 24)
                        
                        // MARK: - Final Lesson Card
                        VStack(spacing: 0) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.06, green: 0.05, blue: 0.12),
                                                Color(red: 0.03, green: 0.03, blue: 0.08)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.35),
                                                Color(red: 0.5, green: 0.7, blue: 1.0).opacity(0.2),
                                                Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.35)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                                
                                VStack(spacing: 10) {
                                    Image(systemName: "graduationcap.fill")
                                        .font(.system(size: 26))
                                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))
                                        .shadow(color: .yellow.opacity(0.4), radius: 6)
                                    
                                    Text("FINAL LESSON")
                                        .font(.system(size: RS.font(12), weight: .bold, design: .monospaced))
                                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))
                                    
                                    Rectangle()
                                        .fill(Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.2))
                                        .frame(width: 160, height: 1)
                                    
                                    Text("Logic gates are the building\nblocks of every computer.")
                                        .font(.system(size: RS.font(13), weight: .medium, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.9))
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(3)
                                    
                                    VStack(spacing: 5) {
                                        lessonRow(gate: "AND", desc: "All inputs must be ON")
                                        lessonRow(gate: "OR", desc: "Any input can be ON")
                                        lessonRow(gate: "XOR", desc: "Only one input ON")
                                        lessonRow(gate: "XNOR", desc: "Inputs must match")
                                        lessonRow(gate: "NOT", desc: "Inverts the signal")
                                        lessonRow(gate: "NOR", desc: "All inputs must be OFF")
                                    }
                                    .padding(.vertical, 2)
                                    
                                    Rectangle()
                                        .fill(Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.15))
                                        .frame(width: 160, height: 1)
                                    
                                    Text("From these simple gates, we\nbuild everything — calculators,\nphones, even AI.")
                                        .font(.system(size: RS.font(11), weight: .medium, design: .monospaced))
                                        .foregroundColor(Color(red: 0.6, green: 0.8, blue: 1.0).opacity(0.8))
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(3)
                                    
                                    Text("You are The Last Circuit. ⚡")
                                        .font(.system(size: RS.font(12), weight: .bold, design: .monospaced))
                                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))
                                        .padding(.top, 2)
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.horizontal, RS.v(25))
                        .opacity(lessonOpacity)
                        
                        Spacer().frame(height: 24)
                        
                        // MARK: - Credits
                        VStack(spacing: 4) {
                            Text("THE LAST CIRCUIT")
                                .font(.system(size: RS.font(10), weight: .bold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.3))
                            
                            Text("Thank you for playing")
                                .font(.system(size: RS.font(11), weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.25))
                        }
                        .opacity(creditsOpacity)
                        
                        // Extra bottom padding to ensure everything is scrollable
                        Spacer().frame(height: 60)
                    }
                }
            }
        }
        .onAppear {
            startAnimationSequence()
        }
        .onReceive(fireflyTimer) { _ in
            updateFireflies()
        }
    }
    
    // MARK: - Lesson Row
    func lessonRow(gate: String, desc: String) -> some View {
        HStack(spacing: 6) {
            Text(gate)
                .font(.system(size: RS.font(10), weight: .bold, design: .monospaced))
                .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))
                .frame(width: 42, alignment: .trailing)
            
            Text("→")
                .font(.system(size: RS.font(10), design: .monospaced))
                .foregroundColor(.white.opacity(0.3))
            
            Text(desc)
                .font(.system(size: RS.font(10), weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - Animation Sequence
    func startAnimationSequence() {
        // 1. Image 1 fades in
        withAnimation(.easeOut(duration: 2.0)) {
            imageOpacity = 1.0
            imageScale = 1.0
        }
        
        // 2. Stars brighten
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            starAlpha = 1.0
        }
        
        // 3. Glow pulse
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            glowPulse = 1.0
        }
        
        // 4. Title appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 1.2)) {
                titleOpacity = 1.0
            }
        }
        
        // 5. Message appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeOut(duration: 1.2)) {
                messageOpacity = 1.0
            }
        }
        
        // 6. Lesson card appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            withAnimation(.easeOut(duration: 1.2)) {
                lessonOpacity = 1.0
            }
        }
        
        // 7. Credits
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            withAnimation(.easeOut(duration: 1.5)) {
                creditsOpacity = 1.0
            }
        }
        
        // 8. Confetti
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showConfetti = true
        }
        
        // 9. Title shimmer loop
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false).delay(2.5)) {
            titleGlowPhase = 2
        }
    }
    
    // MARK: - Firefly Particles
    func updateFireflies() {
        for i in fireflies.indices {
            fireflies[i].y -= fireflies[i].speed
            fireflies[i].x += CGFloat.random(in: -0.8...0.8)
            fireflies[i].opacity -= 0.005
        }
        fireflies.removeAll { $0.y < 0 || $0.opacity <= 0 }
        
        if Double.random(in: 0...1) < 0.35 {
            let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds ?? CGRect(x: 0, y: 0, width: 400, height: 900)
            let particleColor: Color = [
                Color(red: 1.0, green: 0.95, blue: 0.5),  // Gold
                Color(red: 1.0, green: 0.95, blue: 0.5),
                Color(red: 1.0, green: 0.8, blue: 0.3),   // Amber
                Color(red: 1.0, green: 1.0, blue: 0.85)   // Warm white
            ].randomElement()!
            let newParticle = GloryParticle(
                id: UUID(),
                x: CGFloat.random(in: 0...screenBounds.width),
                y: screenBounds.height,
                size: CGFloat.random(in: 2...6),
                speed: CGFloat.random(in: 0.2...1.0),
                opacity: Double.random(in: 0.2...0.6),
                color: particleColor
            )
            fireflies.append(newParticle)
        }
    }
}

// MARK: - Particle Model
struct GloryParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var speed: CGFloat
    var opacity: Double
    var color: Color = Color(red: 1.0, green: 0.95, blue: 0.5)
}

#Preview {
    GloryView()
}
