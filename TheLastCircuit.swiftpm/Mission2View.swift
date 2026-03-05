import SwiftUI
import Combine

struct Mission2View: View {
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
    @State private var villageTransition: Double = 0.0
    @State private var scanLineY: CGFloat = -300
    @State private var borderGlow: Double = 0.5
    @State private var glitchOffset: CGFloat = 0
    @State private var gridOpacity: Double = 0.0
    @State private var hasCompleted: Bool = false
    @State private var showBurst: Bool = false
    
    // Floating particles
    @State private var floatingParticles: [Mission2Particle] = []
    let particleTimer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
    
    // OR Gate: either switch (or both) activates the output
    var eitherSwitchOn: Bool {
        switch1On || switch2On
    }
    
    var body: some View {
        ZStack {
            // MARK: - 1. Dark Night Sky Background
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.01, green: 0.02, blue: 0.08),
                Color(red: 0.04, green: 0.03, blue: 0.12),
                Color(red: 0.02, green: 0.01, blue: 0.06)
            ]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            
            // MARK: - 2. Circuit Grid Background
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<Int(geometry.size.width / 40), id: \.self) { i in
                        Rectangle()
                            .fill(Color.orange.opacity(0.03))
                            .frame(width: 1, height: geometry.size.height)
                            .position(x: CGFloat(i) * 40, y: geometry.size.height / 2)
                    }
                    ForEach(0..<Int(geometry.size.height / 40), id: \.self) { i in
                        Rectangle()
                            .fill(Color.orange.opacity(0.03))
                            .frame(width: geometry.size.width, height: 1)
                            .position(x: geometry.size.width / 2, y: CGFloat(i) * 40)
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .opacity(gridOpacity)
            
            // MARK: - 3. Floating Particles (warm amber)
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
                ForEach(0..<50, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.15...0.5)))
                        .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height * 0.4)
                        )
                }
            }
            
            // MARK: - 5. Main Content
            GeometryReader { geo in
                let screenH = geo.size.height
                let screenW = geo.size.width
                
                VStack(spacing: 8) {
                    // Mission Label
                    Text("MISSION 2 — OR GATE")
                        .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                        .foregroundColor(.orange.opacity(0.6))
                        .padding(.top, 4)
                    
                    // Hint Banner
                    hintBanner(width: screenW)
                    
                    // Village Image
                    villageImage(width: screenW, height: screenH * 0.42)
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
        .onChange(of: eitherSwitchOn, perform: { newValue in
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
            
            Text("Turn ON either switch to restore")
                .font(.system(size: RS.font(11), weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Text("the harbor lights")
                .font(.system(size: RS.font(11), weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
            
            HStack(spacing: 4) {
                Text("Harbor Lights")
                    .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                Text("or")
                    .font(.system(size: RS.font(11), design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
                Text("Backup Generator")
                    .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
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
                        .stroke(Color.orange.opacity(hintGlow * 0.5), lineWidth: 1.5)
                )
        )
        .shadow(color: .orange.opacity(hintGlow * 0.3), radius: RS.v(10))
    }
    
    // MARK: - Village Image
    func villageImage(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            // Dim warm glow behind dark village
            if villageTransition < 0.5 {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.orange.opacity(0.06),
                                Color.blue.opacity(0.04),
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
            
            // Dark village
            Image("VillageDark")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.85, height: height)
                .clipped()
                .opacity(1.0 - villageTransition)
            
            // Lit village
            Image("VillageLit")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.85, height: height)
                .clipped()
                .opacity(villageTransition)
            
            // Glow when lit
            if villageTransition > 0.5 {
                Image("VillageLit")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.85, height: height)
                    .clipped()
                    .blur(radius: RS.v(20))
                    .opacity(0.35 * villageTransition)
                    .blendMode(.screen)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: eitherSwitchOn ? .orange.opacity(0.5) : .orange.opacity(0.04), radius: RS.v(20))
    }
    
    // MARK: - Switches Row
    // MARK: - Pressure Buttons Row
    func switchesRow(width: CGFloat, height: CGFloat) -> some View {
        HStack(spacing: 0) {
            // Button 1: Harbor Lights
            pressureButton(
                name: "Harbor\nLights",
                isPressed: switch1On,
                buttonSize: min(height * 0.55, 100),
                action: {
                    if !hasCompleted {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                            switch1On.toggle()
                        }
                    }
                }
            )
            .frame(width: width * 0.38)
            
            // OR Gate indicator
            VStack(spacing: 4) {
                Text("OR")
                    .font(.system(size: RS.font(12), weight: .bold, design: .monospaced))
                    .foregroundColor(.orange.opacity(0.7))
                
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.orange.opacity(0.4), lineWidth: 1.5)
                        .frame(width: 35, height: 22)
                    
                    Circle()
                        .fill(eitherSwitchOn ? Color.green : Color.red.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .shadow(color: eitherSwitchOn ? .green : .red, radius: 4)
                }
            }
            .frame(width: width * 0.2)
            
            // Button 2: Backup Generator
            pressureButton(
                name: "Backup\nGenerator",
                isPressed: switch2On,
                buttonSize: min(height * 0.55, 100),
                action: {
                    if !hasCompleted {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                            switch2On.toggle()
                        }
                    }
                }
            )
            .frame(width: width * 0.38)
        }
    }
    
    // MARK: - Single Pressure Button
    func pressureButton(name: String, isPressed: Bool, buttonSize: CGFloat, action: @escaping () -> Void) -> some View {
        VStack(spacing: 6) {
            Text(name)
                .font(.system(size: RS.font(13), weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: action) {
                ZStack {
                    // Background glow
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isPressed ? Color.orange.opacity(0.25) : Color.clear)
                        .frame(width: buttonSize + RS.v(24), height: buttonSize + RS.v(24))
                        .blur(radius: RS.v(18))
                    
                    // Tick marks around button edge
                    ForEach(0..<8, id: \.self) { tick in
                        Rectangle()
                            .fill(isPressed ? Color.orange.opacity(0.5) : Color.white.opacity(0.08))
                            .frame(width: RS.v(1.5), height: RS.v(5))
                            .offset(y: -buttonSize / 2 - RS.v(3))
                            .rotationEffect(.degrees(Double(tick) * 45))
                    }
                    
                    // Outer housing
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.15, green: 0.12, blue: 0.1),
                                    Color(red: 0.08, green: 0.06, blue: 0.05)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: buttonSize, height: buttonSize)
                    
                    // Button face — pressed down effect
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: isPressed ? [
                                    Color(red: 0.9, green: 0.5, blue: 0.1),
                                    Color(red: 0.7, green: 0.35, blue: 0.05)
                                ] : [
                                    Color(red: 0.2, green: 0.18, blue: 0.16),
                                    Color(red: 0.12, green: 0.1, blue: 0.08)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: buttonSize - 12, height: buttonSize - 12)
                        .offset(y: isPressed ? 3 : 0)
                        .shadow(color: isPressed ? .orange.opacity(0.5) : .black.opacity(0.3), radius: isPressed ? 10 : 4, y: isPressed ? 0 : 3)
                    
                    // Border with glow
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isPressed ? Color.orange.opacity(0.7) : Color.white.opacity(0.08),
                            lineWidth: isPressed ? 2 : 1.5
                        )
                        .frame(width: buttonSize, height: buttonSize)
                    
                    // Power symbol
                    Image(systemName: isPressed ? "power.circle.fill" : "power.circle")
                        .font(.system(size: buttonSize * 0.3, weight: .medium))
                        .foregroundColor(isPressed ? .white : .white.opacity(0.2))
                        .offset(y: isPressed ? 3 : 0)
                        .shadow(color: isPressed ? .orange.opacity(0.6) : .clear, radius: RS.v(8))
                    
                    // Electric arc when pressed
                    if isPressed {
                        ElectricArc(segments: 6, amplitude: RS.v(3))
                            .stroke(Color.orange.opacity(0.4), lineWidth: 1.5)
                            .frame(width: buttonSize * 0.5, height: RS.v(8))
                            .offset(y: buttonSize * 0.4)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(isPressed ? "PRESSED" : "RELEASED")
                .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                .foregroundColor(isPressed ? .orange : .white.opacity(0.3))
                .shadow(color: isPressed ? .orange.opacity(0.4) : .clear, radius: 4)
        }
    }
    
    // MARK: - Status Indicator
    var statusIndicator: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.orange)
                .frame(width: 8, height: 8)
                .opacity(pulseOpacity)
            Text("HARBOR LIGHTS OFFLINE")
                .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                .foregroundColor(.orange.opacity(0.7))
        }
    }
    
    // MARK: - Completion Flashcard
    var completionFlashcard: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            // Background circuit grid
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<Int(geometry.size.width / 30), id: \.self) { i in
                        Rectangle()
                            .fill(Color.orange.opacity(0.03))
                            .frame(width: 1, height: geometry.size.height)
                            .position(x: CGFloat(i) * 30, y: geometry.size.height / 2)
                    }
                    ForEach(0..<Int(geometry.size.height / 30), id: \.self) { i in
                        Rectangle()
                            .fill(Color.orange.opacity(0.03))
                            .frame(width: geometry.size.width, height: 1)
                            .position(x: geometry.size.width / 2, y: CGFloat(i) * 30)
                    }
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .orange.opacity(0.10), .clear]),
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
                        .fill(Color.orange.opacity(0.08 * borderGlow))
                        .frame(width: 340, height: 420)
                        .blur(radius: RS.v(15))
                    
                    // Card background
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.08, green: 0.05, blue: 0.02),
                                    Color(red: 0.04, green: 0.02, blue: 0.02),
                                    Color(red: 0.06, green: 0.04, blue: 0.0)
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
                                    .orange.opacity(borderGlow),
                                    .yellow.opacity(0.3),
                                    .orange.opacity(borderGlow)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                        .frame(width: RS.v(330), height: RS.v(400))
                    
                    // Scanline overlay on card
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.clear)
                        .frame(width: RS.v(330), height: RS.v(400))
                        .overlay(
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.clear, .orange.opacity(0.06), .clear]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: 60)
                                .offset(y: scanLineY * 0.4)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    VStack(spacing: 24) {
                        // Success icon
                        ZStack {
                            PulsingRing(color: .orange.opacity(0.2), maxRadius: RS.v(40), duration: 2.5)
                            
                            Circle()
                                .stroke(Color.orange.opacity(0.4), lineWidth: 2)
                                .frame(width: RS.v(60), height: RS.v(60))
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: RS.font(40)))
                                .foregroundColor(.orange)
                                .shadow(color: .orange.opacity(0.5), radius: RS.v(8))
                        }
                        
                        // Typing header
                        TypingText(
                            fullText: "MISSION COMPLETE",
                            font: .system(size: RS.font(12), weight: .bold, design: .monospaced),
                            color: .orange,
                            typingSpeed: 0.05
                        )
                        
                        // Divider
                        Rectangle()
                            .fill(Color.orange.opacity(0.3))
                            .frame(width: RS.v(250), height: 1)
                        
                        // Lesson
                        VStack(spacing: 12) {
                            Text("LESSON LEARNED")
                                .font(.system(size: RS.font(14), weight: .bold, design: .monospaced))
                                .foregroundColor(.yellow)
                            
                            Text("OR Gate: If ANY input is ON,\nthe output is ON.")
                                .font(.system(size: RS.font(15), weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, RS.v(20))
                        
                        // Divider
                        Rectangle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 200, height: 1)
                        
                        // Proceed Button
                        Button(action: {
                            onComplete()
                        }) {
                            Text("PROCEED TO MISSION 3")
                                .font(.system(size: RS.font(16), weight: .bold, design: .monospaced))
                                .foregroundColor(.black)
                                .padding(.horizontal, RS.v(30))
                                .padding(.vertical, RS.v(12))
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.orange, Color(red: 1.0, green: 0.7, blue: 0.2)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(RS.v(10))
                                .shadow(color: .orange.opacity(0.5), radius: 8)
                        }
                    }
                    .padding(.vertical, RS.v(20))
                    
                    // Holographic border overlay
                    HolographicBorder(
                        cornerRadius: RS.v(20),
                        width: RS.v(330),
                        height: RS.v(400)
                    )
                    .opacity(0.5)
                }
            .scaleEffect(flashCardScale)
            .opacity(flashCardOpacity)
            
            // Success particle burst
            if showBurst {
                ParticleBurstView(color: .orange, particleCount: 30)
            }
        }
    }
    
    // MARK: - Success Trigger
    func triggerSuccess() {
        hasCompleted = true
        
        // Cross-fade village
        withAnimation(.easeInOut(duration: 1.2)) {
            villageTransition = 1.0
        }
        
        // Flash effect
        withAnimation(.easeIn(duration: 0.15)) {
            successFlash = 0.6
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeOut(duration: 0.8)) {
                successFlash = 0.0
            }
        }
        
        // Show flashcard after delay
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
            floatingParticles[i].opacity -= 0.008
        }
        floatingParticles.removeAll { $0.y < 0 || $0.opacity <= 0 }
        
        if Double.random(in: 0...1) < 0.3 {
            let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds ?? CGRect(x: 0, y: 0, width: 400, height: 900)
            let screenWidth = screenBounds.width
            let screenHeight = screenBounds.height
            let particleColor: Color = [
                .orange, .orange,
                Color(red: 1.0, green: 0.75, blue: 0.3),  // Amber
                Color(red: 1.0, green: 0.85, blue: 0.4)   // Gold
            ].randomElement()!
            let newParticle = Mission2Particle(
                id: UUID(),
                x: CGFloat.random(in: 0...screenWidth),
                y: screenHeight,
                size: CGFloat.random(in: 1.5...5),
                speed: CGFloat.random(in: 0.5...2),
                opacity: Double.random(in: 0.3...0.7),
                color: particleColor
            )
            floatingParticles.append(newParticle)
        }
    }
}

// MARK: - Particle Model
struct Mission2Particle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var speed: CGFloat
    var opacity: Double
    var color: Color = .orange
}

#Preview {
    Mission2View(onComplete: {})
}
