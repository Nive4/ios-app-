import SwiftUI
import Combine

struct GameView: View {
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
    @State private var hospitalTransition: Double = 0.0
    @State private var particleRotation: Double = 0
    @State private var scanLineY: CGFloat = RS.v(-300)
    @State private var borderGlow: Double = 0.5
    @State private var glitchOffset: CGFloat = 0
    @State private var gridOpacity: Double = 0.0
    @State private var hasCompleted: Bool = false
    @State private var showBurst: Bool = false
    @State private var warningPhase: Double = 0
    
    // Floating particles
    @State private var floatingParticles: [GameParticle] = []
    let particleTimer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
    
    var bothSwitchesOn: Bool {
        switch1On && switch2On
    }
    
    var body: some View {
        ZStack {
            // MARK: - 1. Dark Night Sky Background
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.02, green: 0.0, blue: 0.08),
                Color(red: 0.05, green: 0.02, blue: 0.15),
                Color(red: 0.0, green: 0.0, blue: 0.05)
            ]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            
            // MARK: - 2. Circuit Grid Background
            GeometryReader { geometry in
                ZStack {
                    // Vertical circuit lines
                    ForEach(0..<Int(geometry.size.width / 40), id: \.self) { i in
                        Rectangle()
                            .fill(Color.cyan.opacity(0.04))
                            .frame(width: 1, height: geometry.size.height)
                            .position(x: CGFloat(i) * 40, y: geometry.size.height / 2)
                    }
                    // Horizontal circuit lines
                    ForEach(0..<Int(geometry.size.height / 40), id: \.self) { i in
                        Rectangle()
                            .fill(Color.cyan.opacity(0.04))
                            .frame(width: geometry.size.width, height: 1)
                            .position(x: geometry.size.width / 2, y: CGFloat(i) * 40)
                    }
                    
                    // Circuit node dots at intersections
                    ForEach(0..<Int(geometry.size.width / 40), id: \.self) { col in
                        ForEach(0..<Int(geometry.size.height / 40), id: \.self) { row in
                            if Int.random(in: 0...5) == 0 {
                                Circle()
                                    .fill(Color.cyan.opacity(0.08))
                                    .frame(width: 3, height: 3)
                                    .position(x: CGFloat(col) * 40, y: CGFloat(row) * 40)
                            }
                        }
                    }
                }
            }
            .opacity(gridOpacity)
            
            // MARK: - 3. Floating Particles
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
                ForEach(0..<60, id: \.self) { _ in
                    GameStarView()
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
                
                VStack(spacing: RS.v(8)) {
                    // Hint Banner
                    hintBanner(width: screenW)
                        .padding(.top, RS.v(6))
                    
                    // Hospital Image
                    hospitalImage(width: screenW, height: screenH * 0.42)
                        .padding(.top, RS.v(4))
                    
                    // Switches
                    switchesRow(width: screenW, height: screenH * 0.30)
                    
                    // Emergency power indicator
                    if !hasCompleted {
                        emergencyIndicator
                    }
                    
                    Spacer().frame(height: RS.v(4))
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
        .onChange(of: bothSwitchesOn, perform: { newValue in
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
            
            Text("Turn ON both switches to restore power")
                .font(.system(size: RS.font(11), weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            HStack(spacing: 4) {
                Text("Main Power Switch")
                    .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
                Text("&")
                    .font(.system(size: RS.font(11), design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
                Text("Generator Switch")
                    .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
            }
        }
        .padding(.horizontal, RS.v(12))
        .padding(.vertical, RS.v(8))
        .frame(maxWidth: width - RS.v(40))
        .background(
            RoundedRectangle(cornerRadius: RS.v(10))
                .fill(Color.black.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: RS.v(10))
                        .stroke(Color.cyan.opacity(hintGlow * 0.6), lineWidth: RS.v(1.5))
                )
        )
        .shadow(color: .cyan.opacity(hintGlow * 0.4), radius: RS.v(10))
    }
    
    // MARK: - Hospital Image
    func hospitalImage(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            // Dim eerie glow behind the dark hospital
            if hospitalTransition < 0.5 {
                RoundedRectangle(cornerRadius: RS.v(20))
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.cyan.opacity(0.08),
                                Color.purple.opacity(0.05),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: RS.v(30),
                            endRadius: RS.v(200)
                        )
                    )
                    .frame(width: width * 0.9, height: height + RS.v(20))
                    .blur(radius: RS.v(25))
            }
            
            // Dark hospital
            Image("HospitalDark")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.85, height: height)
                .clipped()
                .opacity(1.0 - hospitalTransition)
            
            // Lit hospital
            Image("HospitalLit")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.85, height: height)
                .clipped()
                .opacity(hospitalTransition)
            
            // Glow when lit
            if hospitalTransition > 0.5 {
                Image("HospitalLit")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.85, height: height)
                    .clipped()
                    .blur(radius: RS.v(20))
                    .opacity(0.35 * hospitalTransition)
                    .blendMode(.screen)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: RS.v(8)))
        .shadow(color: bothSwitchesOn ? .yellow.opacity(0.5) : .cyan.opacity(0.06), radius: RS.v(20))
    }
    
    // MARK: - Power Dials Row
    func switchesRow(width: CGFloat, height: CGFloat) -> some View {
        HStack(spacing: 0) {
            // Dial 1: Main Grid
            powerDial(
                name: "Main\nGrid",
                isCharged: switch1On,
                dialSize: min(height * 0.6, RS.v(110)),
                action: {
                    if !hasCompleted {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                            switch1On.toggle()
                        }
                    }
                }
            )
            .frame(width: width * 0.38)
            
            // AND Gate indicator
            VStack(spacing: 4) {
                Text("AND")
                    .font(.system(size: RS.font(10), weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan.opacity(0.6))
                
                ZStack {
                    RoundedRectangle(cornerRadius: RS.v(5))
                        .stroke(Color.cyan.opacity(0.4), lineWidth: RS.v(1.5))
                        .frame(width: RS.v(35), height: RS.v(22))
                    
                    Circle()
                        .fill(bothSwitchesOn ? Color.green : Color.red.opacity(0.6))
                        .frame(width: RS.v(8), height: RS.v(8))
                        .shadow(color: bothSwitchesOn ? .green : .red, radius: RS.v(4))
                }
            }
            .frame(width: width * 0.2)
            
            // Dial 2: Backup Grid
            powerDial(
                name: "Backup\nGrid",
                isCharged: switch2On,
                dialSize: min(height * 0.6, 110),
                action: {
                    if !hasCompleted {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                            switch2On.toggle()
                        }
                    }
                }
            )
            .frame(width: width * 0.38)
        }
    }
    
    // MARK: - Circular Power Dial
    func powerDial(name: String, isCharged: Bool, dialSize: CGFloat, action: @escaping () -> Void) -> some View {
        VStack(spacing: RS.v(6)) {
            // Label
            Text(name)
                .font(.system(size: RS.font(13), weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Dial Button
            Button(action: action) {
                ZStack {
                    // Outer glow when charged
                    Circle()
                        .fill(isCharged ? Color.cyan.opacity(0.2) : Color.clear)
                        .frame(width: dialSize + RS.v(24), height: dialSize + RS.v(24))
                        .blur(radius: RS.v(18))
                    
                    // Tick marks around edge
                    ForEach(0..<12, id: \.self) { tick in
                        Rectangle()
                            .fill(isCharged ? Color.cyan.opacity(0.5) : Color.white.opacity(0.1))
                            .frame(width: RS.v(1.5), height: RS.v(6))
                            .offset(y: -dialSize / 2 - RS.v(4))
                            .rotationEffect(.degrees(Double(tick) * 30))
                    }
                    
                    // Background ring track
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: RS.v(6))
                        .frame(width: dialSize, height: dialSize)
                    
                    // Charged arc (fills when ON)
                    Circle()
                        .trim(from: 0, to: isCharged ? 1.0 : 0.0)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.cyan,
                                    Color(red: 0.0, green: 0.9, blue: 0.7)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: RS.v(6), lineCap: .round)
                        )
                        .frame(width: dialSize, height: dialSize)
                        .rotationEffect(.degrees(-90))
                    
                    // Inner circle body
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    isCharged ? Color(red: 0.05, green: 0.15, blue: 0.2) : Color(red: 0.06, green: 0.06, blue: 0.08),
                                    isCharged ? Color(red: 0.02, green: 0.08, blue: 0.12) : Color(red: 0.03, green: 0.03, blue: 0.05)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: dialSize * 0.4
                            )
                        )
                        .frame(width: dialSize - RS.v(16), height: dialSize - RS.v(16))
                    
                    // Power icon
                    Image(systemName: isCharged ? "bolt.fill" : "bolt.slash")
                        .font(.system(size: dialSize * 0.25, weight: .bold))
                        .foregroundColor(isCharged ? .cyan : .white.opacity(0.25))
                        .shadow(color: isCharged ? .cyan.opacity(0.6) : .clear, radius: RS.v(8))
                    
                    // Electric arc when charged
                    if isCharged {
                        ElectricArc(segments: 8, amplitude: RS.v(4))
                            .stroke(Color.cyan.opacity(0.4), lineWidth: 1.5)
                            .frame(width: dialSize * 0.5, height: RS.v(10))
                            .offset(y: dialSize * 0.35)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Status
            Text(isCharged ? "CHARGED" : "OFFLINE")
                .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                .foregroundColor(isCharged ? .cyan : .red.opacity(0.6))
                .shadow(color: isCharged ? .cyan.opacity(0.4) : .clear, radius: 4)
        }
    }
    
    // MARK: - Emergency Indicator
    var emergencyIndicator: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.red)
                .frame(width: RS.v(10), height: RS.v(10))
                .opacity(pulseOpacity)
            Text("EMERGENCY POWER ACTIVE")
                .font(.system(size: RS.font(12), weight: .bold, design: .monospaced))
                .foregroundColor(.red.opacity(0.8))
        }
        .padding(.horizontal, RS.v(12))
        .padding(.vertical, RS.v(4))
        .background(
            RoundedRectangle(cornerRadius: RS.v(6))
                .fill(Color.red.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: RS.v(6))
                        .stroke(Color.red.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Completion Flashcard
    var completionFlashcard: some View {
        ZStack {
            // Dim background
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            // Background circuit grid
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<Int(geometry.size.width / 30), id: \.self) { i in
                        Rectangle()
                            .fill(Color.cyan.opacity(0.03))
                            .frame(width: 1, height: geometry.size.height)
                            .position(x: CGFloat(i) * 30, y: geometry.size.height / 2)
                    }
                    ForEach(0..<Int(geometry.size.height / 30), id: \.self) { i in
                        Rectangle()
                            .fill(Color.cyan.opacity(0.03))
                            .frame(width: geometry.size.width, height: 1)
                            .position(x: geometry.size.width / 2, y: CGFloat(i) * 30)
                    }
                    
                    // Scan line
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .cyan.opacity(0.12), .clear]),
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
                    RoundedRectangle(cornerRadius: RS.v(22))
                        .fill(Color.green.opacity(0.08 * borderGlow))
                        .frame(width: RS.v(340), height: RS.v(420))
                        .blur(radius: RS.v(15))
                    
                    // Card background
                    RoundedRectangle(cornerRadius: RS.v(20))
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.03, green: 0.08, blue: 0.05),
                                    Color(red: 0.02, green: 0.02, blue: 0.05),
                                    Color(red: 0.0, green: 0.05, blue: 0.08)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: RS.v(330), height: RS.v(400))
                    
                    // Animated border
                    RoundedRectangle(cornerRadius: RS.v(20))
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .green.opacity(borderGlow),
                                    .cyan.opacity(0.3),
                                    .green.opacity(borderGlow)
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
                                        gradient: Gradient(colors: [.clear, .green.opacity(0.06), .clear]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: RS.v(60))
                                .offset(y: scanLineY * 0.4)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    VStack(spacing: 24) {
                        // Success icon
                        ZStack {
                            Circle()
                                .stroke(Color.green.opacity(0.4), lineWidth: RS.v(2))
                                .frame(width: RS.v(60), height: RS.v(60))
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: RS.font(40)))
                                .foregroundColor(.green)
                                .shadow(color: .green.opacity(0.5), radius: RS.v(8))
                        }
                        
                        // Header with glitch
                        ZStack {
                            Text("MISSION COMPLETE")
                                .font(.system(size: RS.font(12), weight: .bold, design: .monospaced))
                                .foregroundColor(.green.opacity(0.3))
                                .offset(x: glitchOffset)
                            
                            Text("MISSION COMPLETE")
                                .font(.system(size: RS.font(12), weight: .bold, design: .monospaced))
                                .foregroundColor(.green)
                        }
                        
                        // Divider
                        Rectangle()
                            .fill(Color.green.opacity(0.3))
                            .frame(width: RS.v(250), height: 1)
                        
                        // Lesson
                        VStack(spacing: 12) {
                            Text("LESSON LEARNED")
                                .font(.system(size: RS.font(14), weight: .bold, design: .monospaced))
                                .foregroundColor(.yellow)
                            
                            Text("AND Gate: Both inputs must be\nON for the output to be ON.")
                                .font(.system(size: RS.font(15), weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, RS.v(20))
                        
                        // Divider
                        Rectangle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: RS.v(200), height: 1)
                        
                        // Proceed Button
                        Button(action: {
                            onComplete()
                        }) {
                            Text("PROCEED TO MISSION 2")
                                .font(.system(size: RS.font(16), weight: .bold, design: .monospaced))
                                .foregroundColor(.black)
                                .padding(.horizontal, RS.v(30))
                                .padding(.vertical, RS.v(12))
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.green, Color(red: 0.0, green: 0.9, blue: 0.5)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(RS.v(10))
                                .shadow(color: .green.opacity(0.5), radius: RS.v(8))
                        }
                    }
                    .padding(.vertical, RS.v(20))
                }
            .scaleEffect(flashCardScale)
            .opacity(flashCardOpacity)
            
            // Success particle burst
            if showBurst {
                ParticleBurstView(color: .green, particleCount: 30)
            }
        }
    }
    
    // MARK: - Success Trigger
    func triggerSuccess() {
        hasCompleted = true
        
        // Cross-fade hospital
        withAnimation(.easeInOut(duration: 1.2)) {
            hospitalTransition = 1.0
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
            scanLineY = RS.v(300)
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
                .cyan, .cyan,
                Color(red: 0.0, green: 0.9, blue: 0.5),  // Green
                Color(red: 0.5, green: 0.8, blue: 1.0)    // Light blue
            ].randomElement()!
            let newParticle = GameParticle(
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

// MARK: - Models

struct GameParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let speed: CGFloat
    var opacity: Double
    var color: Color = .cyan
}

struct GameStarView: View {
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

#Preview {
    GameView(onComplete: {})
}
