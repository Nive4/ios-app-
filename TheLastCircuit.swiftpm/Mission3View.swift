import SwiftUI
import Combine

struct Mission3View: View {
    var onComplete: () -> Void
    
    // Switch States
    @State private var switch1On: Bool = false
    @State private var switch2On: Bool = false
    
    // Animation States
    @State private var pulseOpacity: Double = 0.5
    @State private var hintGlow: Double = 0.6
    @State private var showFlashCard: Bool = false
    @State private var flashCardOpacity: Double = 0.0
    @State private var flashCardScale: CGFloat = 0.8
    @State private var successFlash: Double = 0.0
    @State private var parkTransition: Double = 0.0
    @State private var scanLineY: CGFloat = -300
    @State private var borderGlow: Double = 0.5
    @State private var glitchOffset: CGFloat = 0
    @State private var gridOpacity: Double = 0.0
    @State private var hasCompleted: Bool = false
    @State private var showBurst: Bool = false
    @State private var moonGlow: Double = 0.4
    @State private var waterShimmer: Double = 0.3
    
    // Floating particles
    @State private var floatingParticles: [Mission3Particle] = []
    let particleTimer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
    
    // XOR Gate: only ONE switch must be on (not both, not neither)
    var xorResult: Bool {
        switch1On != switch2On // XOR: true when inputs differ
    }
    
    var body: some View {
        ZStack {
            // MARK: - 1. Deep Night Sky with Mountain Gradient
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.0, green: 0.02, blue: 0.06),
                Color(red: 0.02, green: 0.04, blue: 0.12),
                Color(red: 0.04, green: 0.06, blue: 0.18),
                Color(red: 0.02, green: 0.08, blue: 0.14),
                Color(red: 0.01, green: 0.03, blue: 0.08)
            ]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            
            // MARK: - 2. Moon
            GeometryReader { geo in
                ZStack {
                    // Moon outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.12 * moonGlow),
                                    Color(red: 0.7, green: 0.8, blue: 1.0).opacity(0.06 * moonGlow),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 15,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .position(x: geo.size.width * 0.8, y: geo.size.height * 0.08)
                    
                    // Moon body
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.95, green: 0.95, blue: 0.88),
                                    Color(red: 0.85, green: 0.85, blue: 0.78)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 20
                            )
                        )
                        .frame(width: 36, height: 36)
                        .shadow(color: Color(red: 0.7, green: 0.8, blue: 1.0).opacity(0.6), radius: RS.v(15))
                        .position(x: geo.size.width * 0.8, y: geo.size.height * 0.08)
                }
            }
            
            // MARK: - 3. Stars
            GeometryReader { geometry in
                ForEach(0..<60, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.15...0.6)))
                        .frame(width: CGFloat.random(in: 1...2.5), height: CGFloat.random(in: 1...2.5))
                        .position(
                            x: CGFloat(i * 37 % Int(geometry.size.width)),
                            y: CGFloat.random(in: 0...geometry.size.height * 0.35)
                        )
                }
            }
            
            // MARK: - 4. Water at Bottom
            GeometryReader { geo in
                ZStack {
                    // Water base
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.02, green: 0.06, blue: 0.14).opacity(0.0),
                            Color(red: 0.02, green: 0.06, blue: 0.14).opacity(0.6),
                            Color(red: 0.04, green: 0.1, blue: 0.22).opacity(0.8),
                            Color(red: 0.03, green: 0.08, blue: 0.18)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: geo.size.height * 0.15)
                    .position(x: geo.size.width / 2, y: geo.size.height - geo.size.height * 0.075)
                    
                    // Water shimmer lines
                    ForEach(0..<8, id: \.self) { i in
                        Rectangle()
                            .fill(Color.white.opacity(waterShimmer * Double.random(in: 0.03...0.08)))
                            .frame(width: CGFloat.random(in: 30...80), height: 1)
                            .position(
                                x: CGFloat.random(in: 20...geo.size.width - 20),
                                y: geo.size.height - CGFloat.random(in: 10...geo.size.height * 0.12)
                            )
                    }
                    
                    // Moon reflection in water
                    Ellipse()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.06 * moonGlow),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 5,
                                endRadius: 40
                            )
                        )
                        .frame(width: 60, height: 20)
                        .position(x: geo.size.width * 0.8, y: geo.size.height - geo.size.height * 0.05)
                }
            }
            
            // MARK: - 5. Circuit Grid (subtle teal)
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<Int(geometry.size.width / 40), id: \.self) { i in
                        Rectangle()
                            .fill(Color.teal.opacity(0.025))
                            .frame(width: 1, height: geometry.size.height)
                            .position(x: CGFloat(i) * 40, y: geometry.size.height / 2)
                    }
                    ForEach(0..<Int(geometry.size.height / 40), id: \.self) { i in
                        Rectangle()
                            .fill(Color.teal.opacity(0.025))
                            .frame(width: geometry.size.width, height: 1)
                            .position(x: geometry.size.width / 2, y: CGFloat(i) * 40)
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .opacity(gridOpacity)
            
            // MARK: - 6. Floating Particles (fireflies)
            ForEach(floatingParticles) { particle in
                Circle()
                    .fill(particle.color.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .position(x: particle.x, y: particle.y)
                    .blur(radius: particle.size > 3 ? 1.5 : 0.5)
            }
            
            // CRT scanline overlay
            CRTOverlay(lineSpacing: 4, opacity: 0.03)
                .edgesIgnoringSafeArea(.all)
            
            // MARK: - 7. Main Content
            GeometryReader { geo in
                let screenH = geo.size.height
                let screenW = geo.size.width
                
                VStack(spacing: 8) {
                    // Mission Label
                    Text("MISSION 3 — XOR GATE")
                        .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                        .foregroundColor(.teal.opacity(0.6))
                        .padding(.top, 4)
                    
                    // Hint Banner
                    hintBanner(width: screenW)
                    
                    // Park Image
                    parkImage(width: screenW, height: screenH * 0.42)
                        .padding(.top, 4)
                    
                    // Switches
                    switchesRow(width: screenW, height: screenH * 0.30)
                    
                    // Status indicator
                    if !hasCompleted {
                        statusIndicator
                    }
                    
                    Spacer().frame(height: 4)
                }
            }
            
            // MARK: - 8. Success Flash
            Color.white
                .opacity(successFlash)
                .edgesIgnoringSafeArea(.all)
                .allowsHitTesting(false)
            
            // MARK: - 9. Completion Flashcard
            if showFlashCard {
                completionFlashcard
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.5)) {
                gridOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                hintGlow = 1.0
            }
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulseOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                moonGlow = 1.0
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                waterShimmer = 0.8
            }
        }
        .onReceive(particleTimer) { _ in
            updateParticles()
        }
        .onChange(of: xorResult, perform: { newValue in
            if newValue && !hasCompleted {
                triggerSuccess()
            }
        })
    }
    
    // MARK: - Hint Banner
    func hintBanner(width: CGFloat) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: RS.font(14)))
                Text("HINT")
                    .font(.system(size: RS.font(12), weight: .bold, design: .monospaced))
                    .foregroundColor(.yellow)
            }
            
            Text("Turn ON exactly ONE switch")
                .font(.system(size: RS.font(11), weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Text("to light up the park")
                .font(.system(size: RS.font(11), weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
            
            HStack(spacing: 4) {
                Text("Path Lights")
                    .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                    .foregroundColor(.teal)
                Text("xor")
                    .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
                Text("Lighthouse")
                    .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                    .foregroundColor(.teal)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, RS.v(8))
        .frame(maxWidth: width - 40)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.teal.opacity(hintGlow * 0.5), lineWidth: 1.5)
                )
        )
        .shadow(color: .teal.opacity(hintGlow * 0.3), radius: RS.v(10))
    }
    
    // MARK: - Park Image
    func parkImage(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            // Dim glow behind dark park
            if parkTransition < 0.5 {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.teal.opacity(0.06),
                                Color.indigo.opacity(0.04),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 30,
                            endRadius: 200
                        )
                    )
                    .frame(width: width * 0.9, height: height + 20)
                    .blur(radius: 25)
            }
            
            // Dark park
            Image("ParkDark")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.85, height: height)
                .clipped()
                .opacity(1.0 - parkTransition)
            
            // Lit park
            Image("ParkLit")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.85, height: height)
                .clipped()
                .opacity(parkTransition)
            
            // Glow when lit
            if parkTransition > 0.5 {
                Image("ParkLit")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.85, height: height)
                    .clipped()
                    .blur(radius: RS.v(20))
                    .opacity(0.3 * parkTransition)
                    .blendMode(.screen)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: xorResult ? .green.opacity(0.5) : .teal.opacity(0.04), radius: RS.v(20))
    }
    
    // MARK: - Slider Levers Row
    func switchesRow(width: CGFloat, height: CGFloat) -> some View {
        HStack(spacing: 0) {
            // Lever 1: Path Lights
            sliderLever(
                name: "Path\nLights",
                isUp: switch1On,
                leverHeight: min(height * 0.65, 130),
                action: {
                    if !hasCompleted {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
                            switch1On.toggle()
                        }
                    }
                }
            )
            .frame(width: width * 0.38)
            
            // XOR Gate indicator
            VStack(spacing: 4) {
                Text("XOR")
                    .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                    .foregroundColor(.teal.opacity(0.7))
                
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.teal.opacity(0.4), lineWidth: 1.5)
                        .frame(width: 35, height: 22)
                    
                    Circle()
                        .fill(xorResult ? Color.green : Color.red.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .shadow(color: xorResult ? .green : .red, radius: 4)
                }
                
                // XOR hint
                Text("1 only")
                    .font(.system(size: RS.font(8), weight: .medium, design: .monospaced))
                    .foregroundColor(.teal.opacity(0.4))
            }
            .frame(width: width * 0.2)
            
            // Lever 2: Lighthouse
            sliderLever(
                name: "Light\nhouse",
                isUp: switch2On,
                leverHeight: min(height * 0.65, 130),
                action: {
                    if !hasCompleted {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
                            switch2On.toggle()
                        }
                    }
                }
            )
            .frame(width: width * 0.38)
        }
    }
    
    // MARK: - Single Slider Lever
    func sliderLever(name: String, isUp: Bool, leverHeight: CGFloat, action: @escaping () -> Void) -> some View {
        VStack(spacing: 6) {
            Text(name)
                .font(.system(size: RS.font(13), weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: action) {
                ZStack {
                    // Background glow when up
                    RoundedRectangle(cornerRadius: RS.v(8))
                        .fill(isUp ? Color.teal.opacity(0.2) : Color.clear)
                        .frame(width: RS.v(50), height: leverHeight + RS.v(20))
                        .blur(radius: RS.v(16))
                    
                    // Track groove
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(red: 0.08, green: 0.08, blue: 0.1))
                        .frame(width: 24, height: leverHeight)
                    
                    // Track border
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isUp ? Color.teal.opacity(0.4) : Color.teal.opacity(0.15), lineWidth: isUp ? 1.5 : 1)
                        .frame(width: 24, height: leverHeight)
                    
                    // Fill bar showing state
                    VStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.teal.opacity(isUp ? 0.7 : 0.1),
                                        Color(red: 0.0, green: 0.7, blue: 0.6).opacity(isUp ? 0.5 : 0.05)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 18, height: isUp ? leverHeight * 0.85 : leverHeight * 0.15)
                    }
                    .frame(width: 18, height: leverHeight - 6)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    
                    // Glow trail effect when up
                    if isUp {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.teal.opacity(0.15))
                            .frame(width: 18, height: leverHeight * 0.85)
                            .blur(radius: RS.v(6))
                            .offset(y: -(leverHeight * 0.08))
                    }
                    
                    // Handle knob
                    ZStack {
                        // Handle shadow
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.4))
                            .frame(width: 44, height: 28)
                            .blur(radius: 4)
                        
                        // Handle body
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        isUp ? Color.teal : Color(red: 0.3, green: 0.3, blue: 0.35),
                                        isUp ? Color(red: 0.0, green: 0.5, blue: 0.5) : Color(red: 0.15, green: 0.15, blue: 0.18)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 40, height: 24)
                        
                        // Handle grip lines
                        VStack(spacing: 3) {
                            ForEach(0..<3, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.white.opacity(isUp ? 0.4 : 0.15))
                                    .frame(width: 18, height: 1)
                            }
                        }
                        
                        // Handle border
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isUp ? Color.teal.opacity(0.7) : Color.white.opacity(0.1), lineWidth: 1)
                            .frame(width: 40, height: 24)
                    }
                    .offset(y: isUp ? -(leverHeight * 0.35) : (leverHeight * 0.35))
                    .shadow(color: isUp ? .teal.opacity(0.5) : .clear, radius: RS.v(10))
                    
                    // Electric arc spark at top when up
                    if isUp {
                        ElectricArc(segments: 5, amplitude: RS.v(3))
                            .stroke(Color.teal.opacity(0.4), lineWidth: 1.5)
                            .frame(width: RS.v(30), height: RS.v(6))
                            .offset(y: -(leverHeight * 0.5 + RS.v(6)))
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(isUp ? "UP" : "DOWN")
                .font(.system(size: RS.font(12), weight: .bold, design: .monospaced))
                .foregroundColor(isUp ? .teal : .white.opacity(0.3))
                .shadow(color: isUp ? .teal.opacity(0.4) : .clear, radius: 4)
        }
    }
    
    // MARK: - Status Indicator
    var statusIndicator: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.teal)
                .frame(width: 8, height: 8)
                .opacity(pulseOpacity)
            Text("WHISPER PARK OFFLINE")
                .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                .foregroundColor(.teal.opacity(0.7))
        }
    }
    
    // MARK: - Completion Flashcard
    var completionFlashcard: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<Int(geometry.size.width / 30), id: \.self) { i in
                        Rectangle()
                            .fill(Color.teal.opacity(0.03))
                            .frame(width: 1, height: geometry.size.height)
                            .position(x: CGFloat(i) * 30, y: geometry.size.height / 2)
                    }
                    ForEach(0..<Int(geometry.size.height / 30), id: \.self) { i in
                        Rectangle()
                            .fill(Color.teal.opacity(0.03))
                            .frame(width: geometry.size.width, height: 1)
                            .position(x: geometry.size.width / 2, y: CGFloat(i) * 30)
                    }
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .teal.opacity(0.10), .clear]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width, height: 2)
                        .offset(y: scanLineY)
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            ZStack {
                    // Outer glow
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.teal.opacity(0.08 * borderGlow))
                        .frame(width: 340, height: 420)
                        .blur(radius: RS.v(15))
                    
                    // Card background
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.02, green: 0.06, blue: 0.08),
                                    Color(red: 0.02, green: 0.02, blue: 0.06),
                                    Color(red: 0.0, green: 0.06, blue: 0.06)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: RS.v(330), height: RS.v(400))
                    
                    // Animated border
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .teal.opacity(borderGlow),
                                    .green.opacity(0.3),
                                    .teal.opacity(borderGlow)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                        .frame(width: RS.v(330), height: RS.v(400))
                    
                    // Scanline overlay
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.clear)
                        .frame(width: RS.v(330), height: RS.v(400))
                        .overlay(
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.clear, .teal.opacity(0.06), .clear]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: 60)
                                .offset(y: scanLineY * 0.4)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    VStack(spacing: 24) {
                        // Success icon with pulsing glow
                        ZStack {
                            PulsingRing(color: .teal.opacity(0.15), maxRadius: RS.v(45), duration: 2.0)
                            PulsingRing(color: .green.opacity(0.1), maxRadius: RS.v(35), duration: 3.0)
                            
                            Circle()
                                .stroke(Color.teal.opacity(0.4), lineWidth: 2)
                                .frame(width: RS.v(60), height: RS.v(60))
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: RS.font(40)))
                                .foregroundColor(.teal)
                                .shadow(color: .teal.opacity(0.5), radius: RS.v(8))
                        }
                        
                        // Typing header
                        TypingText(
                            fullText: "MISSION COMPLETE",
                            font: .system(size: RS.font(12), weight: .bold, design: .monospaced),
                            color: .teal,
                            typingSpeed: 0.05
                        )
                        
                        Rectangle()
                            .fill(Color.teal.opacity(0.3))
                            .frame(width: RS.v(250), height: 1)
                        
                        // Lesson
                        VStack(spacing: 12) {
                            Text("LESSON LEARNED")
                                .font(.system(size: RS.font(14), weight: .bold, design: .monospaced))
                                .foregroundColor(.yellow)
                            
                            Text("XOR Gate: Output is ON only\nwhen inputs are DIFFERENT.")
                                .font(.system(size: RS.font(15), weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                            
                            Text("One ON + One OFF = ✅\nBoth ON or Both OFF = ❌")
                                .font(.system(size: RS.font(13), weight: .medium, design: .monospaced))
                                .foregroundColor(.teal.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)
                        }
                        .padding(.horizontal, RS.v(20))
                        
                        Rectangle()
                            .fill(Color.teal.opacity(0.2))
                            .frame(width: 200, height: 1)
                        
                        // Proceed Button
                        Button(action: {
                            onComplete()
                        }) {
                            Text("PROCEED TO MISSION 4")
                                .font(.system(size: RS.font(16), weight: .bold, design: .monospaced))
                                .foregroundColor(.black)
                                .padding(.horizontal, RS.v(30))
                                .padding(.vertical, RS.v(12))
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.teal, Color(red: 0.2, green: 0.9, blue: 0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(RS.v(10))
                                .shadow(color: .teal.opacity(0.5), radius: 8)
                        }
                    }
                    .padding(.vertical, RS.v(20))
                    
                    // Holographic border overlay
                    HolographicBorder(
                        cornerRadius: RS.v(20),
                        width: RS.v(330),
                        height: RS.v(400)
                    )
                    .opacity(0.4)
                }
            .scaleEffect(flashCardScale)
            .opacity(flashCardOpacity)
            
            // Success particle burst
            if showBurst {
                ParticleBurstView(color: .teal, particleCount: 30)
            }
        }
    }
    
    // MARK: - Success Trigger
    func triggerSuccess() {
        hasCompleted = true
        
        withAnimation(.easeInOut(duration: 1.2)) {
            parkTransition = 1.0
        }
        
        withAnimation(.easeIn(duration: 0.15)) {
            successFlash = 0.6
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeOut(duration: 0.8)) {
                successFlash = 0.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showFlashCard = true
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                flashCardOpacity = 1.0
                flashCardScale = 1.0
            }
            
            startFlashcardAnimations()
            showBurst = true
        }
    }
    
    // MARK: - Flashcard Animations
    func startFlashcardAnimations() {
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            scanLineY = 300
        }
        
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            borderGlow = 1.0
        }
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.linear(duration: 0.05)) {
                glitchOffset = CGFloat.random(in: -3...3)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.linear(duration: 0.05)) {
                    glitchOffset = 0
                }
            }
        }
    }
    
    // MARK: - Floating Particles (Firefly-style)
    func updateParticles() {
        for i in floatingParticles.indices {
            floatingParticles[i].y -= floatingParticles[i].speed
            floatingParticles[i].x += CGFloat.random(in: -0.5...0.5) // gentle drift
            floatingParticles[i].opacity -= 0.006
        }
        floatingParticles.removeAll { $0.y < 0 || $0.opacity <= 0 }
        
        if Double.random(in: 0...1) < 0.25 {
            let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds ?? CGRect(x: 0, y: 0, width: 400, height: 900)
            let screenWidth = screenBounds.width
            let screenHeight = screenBounds.height
            let particleColor: Color = [
                Color(red: 0.6, green: 1.0, blue: 0.5),
                Color(red: 0.6, green: 1.0, blue: 0.5),
                Color(red: 0.4, green: 0.9, blue: 0.8),  // Teal
                Color(red: 0.8, green: 1.0, blue: 0.3)   // Yellow-green
            ].randomElement()!
            let newParticle = Mission3Particle(
                id: UUID(),
                x: CGFloat.random(in: 0...screenWidth),
                y: screenHeight * CGFloat.random(in: 0.5...1.0),
                size: CGFloat.random(in: 2...6),
                speed: CGFloat.random(in: 0.3...1.5),
                opacity: Double.random(in: 0.4...0.9),
                color: particleColor
            )
            floatingParticles.append(newParticle)
        }
    }
}

// MARK: - Particle Model
struct Mission3Particle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var speed: CGFloat
    var opacity: Double
    var color: Color = Color(red: 0.6, green: 1.0, blue: 0.5)
}

#Preview {
    Mission3View(onComplete: {})
}
