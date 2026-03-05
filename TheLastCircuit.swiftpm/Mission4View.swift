import SwiftUI
import Combine

struct Mission4View: View {
    var onComplete: () -> Void
    
    // Switch States
    @State private var switch1On: Bool = false
    @State private var switch2On: Bool = true
    @State private var hasInteracted: Bool = false
    
    // Animation States
    @State private var pulseOpacity: Double = 0.5
    @State private var hintGlow: Double = 0.6
    @State private var showFlashCard: Bool = false
    @State private var flashCardOpacity: Double = 0.0
    @State private var flashCardScale: CGFloat = 0.8
    @State private var successFlash: Double = 0.0
    @State private var academyTransition: Double = 0.0
    @State private var scanLineY: CGFloat = -300
    @State private var borderGlow: Double = 0.5
    @State private var glitchOffset: CGFloat = 0
    @State private var gridOpacity: Double = 0.0
    @State private var hasCompleted: Bool = false
    @State private var showBurst: Bool = false
    
    // Floating particles
    @State private var floatingParticles: [Mission4Particle] = []
    let particleTimer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
    
    // XNOR Gate: output is ON when both inputs are the SAME
    var xnorResult: Bool {
        switch1On == switch2On // XNOR: true when inputs match
    }
    
    // XNOR gate solved when both inputs match (after player interacts)
    var puzzleSolved: Bool {
        hasInteracted && xnorResult
    }
    
    var body: some View {
        ZStack {
            // MARK: - 1. Dark Gothic Background
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.04, green: 0.0, blue: 0.06),
                Color(red: 0.08, green: 0.02, blue: 0.12),
                Color(red: 0.06, green: 0.0, blue: 0.10),
                Color(red: 0.03, green: 0.0, blue: 0.05)
            ]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            
            // MARK: - 2. Circuit Grid (purple tint)
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<Int(geometry.size.width / 40), id: \.self) { i in
                        Rectangle()
                            .fill(Color.purple.opacity(0.03))
                            .frame(width: 1, height: geometry.size.height)
                            .position(x: CGFloat(i) * 40, y: geometry.size.height / 2)
                    }
                    ForEach(0..<Int(geometry.size.height / 40), id: \.self) { i in
                        Rectangle()
                            .fill(Color.purple.opacity(0.03))
                            .frame(width: geometry.size.width, height: 1)
                            .position(x: geometry.size.width / 2, y: CGFloat(i) * 40)
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .opacity(gridOpacity)
            
            // MARK: - 3. Floating Particles (embers)
            ForEach(floatingParticles) { particle in
                Circle()
                    .fill(particle.color.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .position(x: particle.x, y: particle.y)
                    .blur(radius: particle.size > 3.5 ? 1 : 0)
            }
            
            // CRT scanline overlay
            CRTOverlay(lineSpacing: 4, opacity: 0.03)
                .edgesIgnoringSafeArea(.all)
            
            // MARK: - 4. Stars
            GeometryReader { geometry in
                ForEach(0..<45, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.1...0.45)))
                        .frame(width: CGFloat.random(in: 1...2.5), height: CGFloat.random(in: 1...2.5))
                        .position(
                            x: CGFloat(i * 41 % Int(geometry.size.width)),
                            y: CGFloat.random(in: 0...geometry.size.height * 0.35)
                        )
                }
            }
            
            // MARK: - 5. Main Content
            GeometryReader { geo in
                let screenH = geo.size.height
                let screenW = geo.size.width
                
                VStack(spacing: 8) {
                    // Mission Label
                    Text("MISSION 4 — XNOR GATE")
                        .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                        .foregroundColor(.purple.opacity(0.6))
                        .padding(.top, 4)
                    
                    // Hint Banner
                    hintBanner(width: screenW)
                    
                    // Academy Image
                    academyImage(width: screenW, height: screenH * 0.42)
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
            
            // MARK: - 6. Success Flash
            Color.white
                .opacity(successFlash)
                .edgesIgnoringSafeArea(.all)
                .allowsHitTesting(false)
            
            // MARK: - 7. Completion Flashcard
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
        }
        .onReceive(particleTimer) { _ in
            updateParticles()
        }
        .onChange(of: puzzleSolved, perform: { newValue in
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
            
            Text("Turn ON both switches together")
                .font(.system(size: RS.font(11), weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Text("to restore the academy lights")
                .font(.system(size: RS.font(11), weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
            
            HStack(spacing: 4) {
                Text("Hall Lights")
                    .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 0.7, green: 0.5, blue: 1.0))
                Text("xnor")
                    .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
                Text("Tower Beacon")
                    .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 0.7, green: 0.5, blue: 1.0))
            }
            
            Text("(Both must match!)")
                .font(.system(size: RS.font(9), weight: .medium, design: .monospaced))
                .foregroundColor(.purple.opacity(0.5))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, RS.v(8))
        .frame(maxWidth: width - 40)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.purple.opacity(hintGlow * 0.5), lineWidth: 1.5)
                )
        )
        .shadow(color: .purple.opacity(hintGlow * 0.3), radius: RS.v(10))
    }
    
    // MARK: - Academy Image
    func academyImage(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            // Dim gothic glow behind dark academy
            if academyTransition < 0.5 {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.purple.opacity(0.08),
                                Color(red: 0.3, green: 0.1, blue: 0.4).opacity(0.05),
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
            
            // Dark academy
            Image("AcademyDark")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.85, height: height)
                .clipped()
                .opacity(1.0 - academyTransition)
            
            // Lit academy
            Image("AcademyLit")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.85, height: height)
                .clipped()
                .opacity(academyTransition)
            
            // Warm glow when lit
            if academyTransition > 0.5 {
                Image("AcademyLit")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.85, height: height)
                    .clipped()
                    .blur(radius: RS.v(20))
                    .opacity(0.35 * academyTransition)
                    .blendMode(.screen)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: puzzleSolved ? Color(red: 0.7, green: 0.5, blue: 1.0).opacity(0.5) : .purple.opacity(0.04), radius: RS.v(20))
    }
    
    // MARK: - Sync Wheels Row
    func switchesRow(width: CGFloat, height: CGFloat) -> some View {
        HStack(spacing: 0) {
            // Wheel 1: Hall Signal
            syncWheel(
                name: "Hall\nSignal",
                pointsUp: switch1On,
                wheelSize: min(height * 0.6, 110),
                action: {
                    if !hasCompleted {
                        hasInteracted = true
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            switch1On.toggle()
                        }
                    }
                }
            )
            .frame(width: width * 0.38)
            
            // XNOR Gate indicator
            VStack(spacing: 4) {
                Text("XNOR")
                    .font(.system(size: RS.font(10), weight: .bold, design: .monospaced))
                    .foregroundColor(.purple.opacity(0.7))
                
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.purple.opacity(0.4), lineWidth: 1.5)
                        .frame(width: 38, height: 22)
                    
                    Circle()
                        .fill(xnorResult ? Color.green : Color.red.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .shadow(color: xnorResult ? .green : .red, radius: 4)
                }
                
                Text(xnorResult ? "SYNCED" : "OUT OF\nSYNC")
                    .font(.system(size: RS.font(7), weight: .bold, design: .monospaced))
                    .foregroundColor(xnorResult ? .green.opacity(0.7) : .red.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
            .frame(width: width * 0.2)
            
            // Wheel 2: Tower Signal
            syncWheel(
                name: "Tower\nSignal",
                pointsUp: switch2On,
                wheelSize: min(height * 0.6, 110),
                action: {
                    if !hasCompleted {
                        hasInteracted = true
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            switch2On.toggle()
                        }
                    }
                }
            )
            .frame(width: width * 0.38)
        }
    }
    
    // MARK: - Single Sync Wheel
    func syncWheel(name: String, pointsUp: Bool, wheelSize: CGFloat, action: @escaping () -> Void) -> some View {
        VStack(spacing: 6) {
            Text(name)
                .font(.system(size: RS.font(13), weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: action) {
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(xnorResult ? Color.purple.opacity(0.2) : Color.clear)
                        .frame(width: wheelSize + RS.v(24), height: wheelSize + RS.v(24))
                        .blur(radius: RS.v(18))
                    
                    // Pulsing outer ring when synced
                    if xnorResult {
                        Circle()
                            .stroke(Color.purple.opacity(0.15), lineWidth: RS.v(2))
                            .frame(width: wheelSize + RS.v(16), height: wheelSize + RS.v(16))
                    }
                    
                    // Ring track
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.purple.opacity(xnorResult ? 0.4 : 0.2),
                                    Color(red: 0.5, green: 0.3, blue: 0.7).opacity(xnorResult ? 0.3 : 0.15)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: RS.v(5)
                        )
                        .frame(width: wheelSize, height: wheelSize)
                    
                    // Inner disc
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.1, green: 0.05, blue: 0.14),
                                    Color(red: 0.05, green: 0.02, blue: 0.08)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: wheelSize * 0.4
                            )
                        )
                        .frame(width: wheelSize - 12, height: wheelSize - 12)
                    
                    // Direction arrow
                    Image(systemName: "arrow.up")
                        .font(.system(size: wheelSize * 0.3, weight: .bold))
                        .foregroundColor(Color(red: 0.7, green: 0.5, blue: 1.0))
                        .rotationEffect(.degrees(pointsUp ? 0 : 180))
                        .shadow(color: .purple.opacity(0.6), radius: RS.v(8))
                    
                    // Tick marks around the edge
                    ForEach(0..<12, id: \.self) { i in
                        Rectangle()
                            .fill(xnorResult ? Color.purple.opacity(i % 3 == 0 ? 0.6 : 0.3) : Color.purple.opacity(i % 3 == 0 ? 0.4 : 0.15))
                            .frame(width: i % 3 == 0 ? RS.v(2) : RS.v(1), height: i % 3 == 0 ? RS.v(8) : RS.v(5))
                            .offset(y: -(wheelSize / 2 - RS.v(6)))
                            .rotationEffect(.degrees(Double(i) * 30))
                    }
                    
                    // Border
                    Circle()
                        .stroke(Color(red: 0.7, green: 0.5, blue: 1.0).opacity(xnorResult ? 0.5 : 0.3), lineWidth: xnorResult ? 2 : 1.5)
                        .frame(width: wheelSize, height: wheelSize)
                    
                    // Electric arc when synced
                    if xnorResult {
                        ElectricArc(segments: 8, amplitude: RS.v(4))
                            .stroke(Color.purple.opacity(0.4), lineWidth: 1.5)
                            .frame(width: wheelSize * 0.5, height: RS.v(10))
                            .offset(y: wheelSize * 0.4)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(pointsUp ? "↑ UP" : "↓ DOWN")
                .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                .foregroundColor(Color(red: 0.7, green: 0.5, blue: 1.0))
                .shadow(color: .purple.opacity(0.3), radius: 4)
        }
    }
    
    // MARK: - Status Indicator
    var statusIndicator: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.purple)
                .frame(width: 8, height: 8)
                .opacity(pulseOpacity)
            Text("ACADEMY POWER OFFLINE")
                .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                .foregroundColor(.purple.opacity(0.7))
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
                            .fill(Color.purple.opacity(0.03))
                            .frame(width: 1, height: geometry.size.height)
                            .position(x: CGFloat(i) * 30, y: geometry.size.height / 2)
                    }
                    ForEach(0..<Int(geometry.size.height / 30), id: \.self) { i in
                        Rectangle()
                            .fill(Color.purple.opacity(0.03))
                            .frame(width: geometry.size.width, height: 1)
                            .position(x: geometry.size.width / 2, y: CGFloat(i) * 30)
                    }
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .purple.opacity(0.10), .clear]),
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
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.purple.opacity(0.08 * borderGlow))
                        .frame(width: 340, height: 440)
                        .blur(radius: RS.v(15))
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.06, green: 0.02, blue: 0.08),
                                    Color(red: 0.03, green: 0.01, blue: 0.05),
                                    Color(red: 0.05, green: 0.0, blue: 0.07)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: RS.v(330), height: RS.v(420))
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .purple.opacity(borderGlow),
                                    Color(red: 0.7, green: 0.5, blue: 1.0).opacity(0.3),
                                    .purple.opacity(borderGlow)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                        .frame(width: RS.v(330), height: RS.v(420))
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.clear)
                        .frame(width: RS.v(330), height: RS.v(420))
                        .overlay(
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.clear, .purple.opacity(0.06), .clear]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: 60)
                                .offset(y: scanLineY * 0.4)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    VStack(spacing: RS.v(20)) {
                        ZStack {
                            PulsingRing(color: .purple.opacity(0.15), maxRadius: RS.v(45), duration: 2.5)
                            PulsingRing(color: Color(red: 0.7, green: 0.5, blue: 1.0).opacity(0.1), maxRadius: RS.v(38), duration: 3.5)
                            
                            Circle()
                                .stroke(Color.purple.opacity(0.4), lineWidth: 2)
                                .frame(width: RS.v(60), height: RS.v(60))
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: RS.font(40)))
                                .foregroundColor(Color(red: 0.7, green: 0.5, blue: 1.0))
                                .shadow(color: .purple.opacity(0.5), radius: RS.v(8))
                        }
                        
                        // Typing header
                        TypingText(
                            fullText: "MISSION COMPLETE",
                            font: .system(size: RS.font(12), weight: .bold, design: .monospaced),
                            color: Color(red: 0.7, green: 0.5, blue: 1.0),
                            typingSpeed: 0.05
                        )
                        
                        Rectangle()
                            .fill(Color.purple.opacity(0.3))
                            .frame(width: RS.v(250), height: 1)
                        
                        VStack(spacing: 10) {
                            Text("LESSON LEARNED")
                                .font(.system(size: RS.font(14), weight: .bold, design: .monospaced))
                                .foregroundColor(.yellow)
                            
                            Text("XNOR Gate: Output is ON\nwhen inputs are the SAME.")
                                .font(.system(size: RS.font(15), weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                            
                            Text("Both ON or Both OFF = ✅\nOne ON + One OFF = ❌")
                                .font(.system(size: RS.font(13), weight: .medium, design: .monospaced))
                                .foregroundColor(.purple.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)
                            
                            Text("(Opposite of XOR!)")
                                .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                                .foregroundColor(.purple.opacity(0.5))
                        }
                        .padding(.horizontal, RS.v(20))
                        
                        Rectangle()
                            .fill(Color.purple.opacity(0.2))
                            .frame(width: 200, height: 1)
                        
                        Button(action: {
                            onComplete()
                        }) {
                            Text("PROCEED TO MISSION 5")
                                .font(.system(size: RS.font(16), weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.horizontal, RS.v(30))
                                .padding(.vertical, RS.v(12))
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.5, green: 0.2, blue: 0.8),
                                            Color(red: 0.7, green: 0.4, blue: 1.0)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(RS.v(10))
                                .shadow(color: .purple.opacity(0.5), radius: 8)
                        }
                    }
                    .padding(.vertical, RS.v(20))
                    
                    // Holographic border overlay
                    HolographicBorder(
                        cornerRadius: RS.v(20),
                        width: RS.v(330),
                        height: RS.v(420)
                    )
                    .opacity(0.4)
                }
            .scaleEffect(flashCardScale)
            .opacity(flashCardOpacity)
            
            // Success particle burst
            if showBurst {
                ParticleBurstView(color: .purple, particleCount: 30)
            }
        }
    }
    
    // MARK: - Success Trigger
    func triggerSuccess() {
        hasCompleted = true
        
        withAnimation(.easeInOut(duration: 1.2)) {
            academyTransition = 1.0
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
    
    // MARK: - Floating Particles
    func updateParticles() {
        for i in floatingParticles.indices {
            floatingParticles[i].y -= floatingParticles[i].speed
            floatingParticles[i].opacity -= 0.007
        }
        floatingParticles.removeAll { $0.y < 0 || $0.opacity <= 0 }
        
        if Double.random(in: 0...1) < 0.25 {
            let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds ?? CGRect(x: 0, y: 0, width: 400, height: 900)
            let screenWidth = screenBounds.width
            let screenHeight = screenBounds.height
            let particleColor: Color = [
                Color(red: 0.8, green: 0.5, blue: 1.0),
                Color(red: 0.8, green: 0.5, blue: 1.0),
                Color(red: 0.6, green: 0.3, blue: 0.9),  // Deep purple
                Color(red: 0.9, green: 0.7, blue: 1.0)   // Lavender
            ].randomElement()!
            let newParticle = Mission4Particle(
                id: UUID(),
                x: CGFloat.random(in: 0...screenWidth),
                y: screenHeight,
                size: CGFloat.random(in: 1.5...5),
                speed: CGFloat.random(in: 0.4...1.8),
                opacity: Double.random(in: 0.3...0.7),
                color: particleColor
            )
            floatingParticles.append(newParticle)
        }
    }
}

// MARK: - Particle Model
struct Mission4Particle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var speed: CGFloat
    var opacity: Double
    var color: Color = Color(red: 0.8, green: 0.5, blue: 1.0)
}

#Preview {
    Mission4View(onComplete: {})
}
