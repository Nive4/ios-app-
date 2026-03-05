import SwiftUI
import Combine

struct Mission5View: View {
    var onComplete: () -> Void
    
    // NOT Gate: single switch, starts ON (override blocking power)
    // User must turn it OFF to restore lights (inverted logic!)
    @State private var overrideOn: Bool = true
    
    // Animation States
    @State private var pulseOpacity: Double = 0.5
    @State private var hintGlow: Double = 0.6
    @State private var showFlashCard: Bool = false
    @State private var flashCardOpacity: Double = 0.0
    @State private var flashCardScale: CGFloat = 0.8
    @State private var successFlash: Double = 0.0
    @State private var theaterTransition: Double = 0.0
    @State private var scanLineY: CGFloat = -300
    @State private var borderGlow: Double = 0.5
    @State private var glitchOffset: CGFloat = 0
    @State private var gridOpacity: Double = 0.0
    @State private var hasCompleted: Bool = false
    @State private var showBurst: Bool = false
    
    // Floating particles
    @State private var floatingParticles: [Mission5Particle] = []
    let particleTimer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
    
    // NOT Gate: output is the INVERSE of input
    // Override ON → lights OFF; Override OFF → lights ON
    var notResult: Bool {
        !overrideOn
    }
    
    var body: some View {
        ZStack {
            // MARK: - 1. Dark Deserted Background
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.03, green: 0.03, blue: 0.04),
                Color(red: 0.06, green: 0.05, blue: 0.07),
                Color(red: 0.04, green: 0.03, blue: 0.05),
                Color(red: 0.02, green: 0.02, blue: 0.03)
            ]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            
            // MARK: - 2. Circuit Grid (crimson tint)
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<Int(geometry.size.width / 40), id: \.self) { i in
                        Rectangle()
                            .fill(Color.red.opacity(0.025))
                            .frame(width: 1, height: geometry.size.height)
                            .position(x: CGFloat(i) * 40, y: geometry.size.height / 2)
                    }
                    ForEach(0..<Int(geometry.size.height / 40), id: \.self) { i in
                        Rectangle()
                            .fill(Color.red.opacity(0.025))
                            .frame(width: geometry.size.width, height: 1)
                            .position(x: geometry.size.width / 2, y: CGFloat(i) * 40)
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .opacity(gridOpacity)
            
            // MARK: - 3. Floating Particles (dust motes)
            ForEach(floatingParticles) { particle in
                Circle()
                    .fill(particle.color.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .position(x: particle.x, y: particle.y)
                    .blur(radius: particle.size > 3 ? 1 : 0)
            }
            
            // CRT scanline overlay
            CRTOverlay(lineSpacing: 4, opacity: 0.03)
                .edgesIgnoringSafeArea(.all)
            
            // MARK: - 4. Stars
            GeometryReader { geometry in
                ForEach(0..<35, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.1...0.4)))
                        .frame(width: CGFloat.random(in: 1...2), height: CGFloat.random(in: 1...2))
                        .position(
                            x: CGFloat(i * 43 % Int(geometry.size.width)),
                            y: CGFloat.random(in: 0...geometry.size.height * 0.3)
                        )
                }
            }
            
            // MARK: - 5. Main Content
            GeometryReader { geo in
                let screenH = geo.size.height
                let screenW = geo.size.width
                
                VStack(spacing: 10) {
                    // Mission Label
                    Text("MISSION 5 — NOT GATE")
                        .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 0.9, green: 0.3, blue: 0.3).opacity(0.6))
                        .padding(.top, 4)
                    
                    // Hint Banner
                    hintBanner(width: screenW)
                    
                    // Theater Image
                    theaterImage(width: screenW, height: screenH * 0.38)
                        .padding(.top, 6)
                    
                    // NOT Gate Diagram
                    notGateDiagram(width: screenW)
                        .padding(.vertical, RS.v(8))
                    
                    // Single Switch (centered)
                    singleSwitchView(width: screenW, height: screenH * 0.28)
                    
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
        .onChange(of: notResult, perform: { newValue in
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
            
            Text("The override is BLOCKING power!")
                .font(.system(size: RS.font(11), weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Text("Turn it OFF to restore lights")
                .font(.system(size: RS.font(11), weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
            
            Text("NOT gate inverts the signal!")
                .font(.system(size: RS.font(10), weight: .bold, design: .monospaced))
                .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, RS.v(8))
        .frame(maxWidth: width - 40)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.red.opacity(hintGlow * 0.4), lineWidth: 1.5)
                )
        )
        .shadow(color: .red.opacity(hintGlow * 0.2), radius: RS.v(10))
    }
    
    // MARK: - Theater Image
    func theaterImage(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            // Dim red glow behind dark theater
            if theaterTransition < 0.5 {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.red.opacity(0.05),
                                Color(red: 0.4, green: 0.1, blue: 0.1).opacity(0.04),
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
            
            // Dark theater
            Image("TheaterDark")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.9, height: height)
                .clipped()
                .opacity(1.0 - theaterTransition)
            
            // Lit theater
            Image("TheaterLit")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.9, height: height)
                .clipped()
                .opacity(theaterTransition)
            
            // Glow when lit
            if theaterTransition > 0.5 {
                Image("TheaterLit")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.9, height: height)
                    .clipped()
                    .blur(radius: RS.v(20))
                    .opacity(0.35 * theaterTransition)
                    .blendMode(.screen)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: notResult ? Color(red: 1.0, green: 0.6, blue: 0.3).opacity(0.5) : .red.opacity(0.04), radius: RS.v(20))
    }
    
    // MARK: - NOT Gate Diagram
    func notGateDiagram(width: CGFloat) -> some View {
        HStack(spacing: 12) {
            // Input
            VStack(spacing: 2) {
                Text("INPUT")
                    .font(.system(size: RS.font(8), weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
                Circle()
                    .fill(overrideOn ? Color.green : Color.red.opacity(0.6))
                    .frame(width: 10, height: 10)
                    .shadow(color: overrideOn ? .green : .red, radius: 3)
                Text(overrideOn ? "ON" : "OFF")
                    .font(.system(size: RS.font(8), weight: .bold, design: .monospaced))
                    .foregroundColor(overrideOn ? .green : .red)
            }
            
            // Arrow
            Image(systemName: "arrow.right")
                .font(.system(size: RS.font(14)))
                .foregroundColor(.white.opacity(0.3))
            
            // NOT Gate symbol
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.red.opacity(0.5), lineWidth: 1.5)
                    .frame(width: 45, height: 24)
                
                Text("NOT")
                    .font(.system(size: RS.font(9), weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
            }
            
            // Arrow
            Image(systemName: "arrow.right")
                .font(.system(size: RS.font(14)))
                .foregroundColor(.white.opacity(0.3))
            
            // Output
            VStack(spacing: 2) {
                Text("OUTPUT")
                    .font(.system(size: RS.font(8), weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
                Circle()
                    .fill(notResult ? Color.green : Color.red.opacity(0.6))
                    .frame(width: 10, height: 10)
                    .shadow(color: notResult ? .green : .red, radius: 3)
                Text(notResult ? "ON" : "OFF")
                    .font(.system(size: RS.font(8), weight: .bold, design: .monospaced))
                    .foregroundColor(notResult ? .green : .red)
            }
        }
        .padding(.horizontal, RS.v(20))
        .padding(.vertical, RS.v(8))
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.red.opacity(0.15), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Kill Switch Panel (Centered)
    func singleSwitchView(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 10) {
            // Warning label
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: RS.font(12)))
                    .foregroundColor(overrideOn ? .red : .green)
                Text(overrideOn ? "DANGER — OVERRIDE ACTIVE" : "SYSTEM CLEAR")
                    .font(.system(size: RS.font(10), weight: .bold, design: .monospaced))
                    .foregroundColor(overrideOn ? .red.opacity(0.8) : .green.opacity(0.8))
            }
            
            Button(action: {
                if !hasCompleted {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        overrideOn.toggle()
                    }
                }
            }) {
                ZStack {
                    // Outer danger glow
                    Circle()
                        .fill(overrideOn ? Color.red.opacity(0.25) : Color.green.opacity(0.2))
                        .frame(width: height * 0.8, height: height * 0.8)
                        .blur(radius: RS.v(22))
                    
                    // Pulsing warning ring
                    if overrideOn {
                        Circle()
                            .stroke(Color.red.opacity(0.15), lineWidth: RS.v(2))
                            .frame(width: height * 0.72, height: height * 0.72)
                    }
                    
                    // Hexagonal housing
                    RegularPolygon(sides: 6)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.12, green: 0.1, blue: 0.1),
                                    Color(red: 0.06, green: 0.04, blue: 0.04)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: height * 0.6, height: height * 0.6)
                    
                    // Hexagonal border
                    RegularPolygon(sides: 6)
                        .stroke(
                            overrideOn ? Color.red.opacity(0.7) : Color.green.opacity(0.6),
                            lineWidth: overrideOn ? 2.5 : 2
                        )
                        .frame(width: height * 0.6, height: height * 0.6)
                    
                    // Inner button face
                    RegularPolygon(sides: 6)
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: overrideOn ? [
                                    Color(red: 0.7, green: 0.15, blue: 0.1),
                                    Color(red: 0.4, green: 0.05, blue: 0.03)
                                ] : [
                                    Color(red: 0.1, green: 0.5, blue: 0.2),
                                    Color(red: 0.05, green: 0.25, blue: 0.1)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: height * 0.22
                            )
                        )
                        .frame(width: height * 0.45, height: height * 0.45)
                        .shadow(color: overrideOn ? .red.opacity(0.5) : .green.opacity(0.4), radius: RS.v(12))
                    
                    // Icon
                    Image(systemName: overrideOn ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .font(.system(size: height * 0.12, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: overrideOn ? .red.opacity(0.6) : .green.opacity(0.6), radius: RS.v(8))
                    
                    // Corner warning dots with glow
                    ForEach(0..<6, id: \.self) { i in
                        Circle()
                            .fill(overrideOn ? Color.red.opacity(0.4) : Color.green.opacity(0.3))
                            .frame(width: RS.v(6), height: RS.v(6))
                            .shadow(color: overrideOn ? .red.opacity(0.3) : .green.opacity(0.2), radius: RS.v(4))
                            .offset(y: -(height * 0.32))
                            .rotationEffect(.degrees(Double(i) * 60))
                    }
                    
                    // Electric arcs when active
                    if overrideOn {
                        ElectricArc(segments: 6, amplitude: RS.v(3))
                            .stroke(Color.red.opacity(0.35), lineWidth: 1.5)
                            .frame(width: height * 0.4, height: RS.v(8))
                            .offset(y: height * 0.35)
                        
                        ElectricArc(segments: 5, amplitude: RS.v(2.5))
                            .stroke(Color.red.opacity(0.25), lineWidth: 1)
                            .frame(width: height * 0.3, height: RS.v(6))
                            .offset(y: -(height * 0.35))
                            .rotationEffect(.degrees(180))
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(overrideOn ? "ACTIVE" : "DISABLED")
                .font(.system(size: RS.font(14), weight: .bold, design: .monospaced))
                .foregroundColor(overrideOn ? .red : .green)
                .shadow(color: overrideOn ? .red.opacity(0.5) : .green.opacity(0.5), radius: 5)
        }
    }
    
    // MARK: - Status Indicator
    var statusIndicator: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
                .opacity(pulseOpacity)
            Text("OVERRIDE ACTIVE — POWER BLOCKED")
                .font(.system(size: RS.font(10), weight: .bold, design: .monospaced))
                .foregroundColor(.red.opacity(0.7))
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
                            .fill(Color.red.opacity(0.03))
                            .frame(width: 1, height: geometry.size.height)
                            .position(x: CGFloat(i) * 30, y: geometry.size.height / 2)
                    }
                    ForEach(0..<Int(geometry.size.height / 30), id: \.self) { i in
                        Rectangle()
                            .fill(Color.red.opacity(0.03))
                            .frame(width: geometry.size.width, height: 1)
                            .position(x: geometry.size.width / 2, y: CGFloat(i) * 30)
                    }
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .red.opacity(0.10), .clear]),
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
                        .fill(Color.red.opacity(0.08 * borderGlow))
                        .frame(width: 340, height: 420)
                        .blur(radius: RS.v(15))
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.08, green: 0.02, blue: 0.02),
                                    Color(red: 0.04, green: 0.01, blue: 0.01),
                                    Color(red: 0.06, green: 0.02, blue: 0.0)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: RS.v(330), height: RS.v(400))
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.4, blue: 0.3).opacity(borderGlow),
                                    Color(red: 1.0, green: 0.6, blue: 0.3).opacity(0.3),
                                    Color(red: 1.0, green: 0.4, blue: 0.3).opacity(borderGlow)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                        .frame(width: RS.v(330), height: RS.v(400))
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.clear)
                        .frame(width: RS.v(330), height: RS.v(400))
                        .overlay(
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.clear, .red.opacity(0.06), .clear]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: 60)
                                .offset(y: scanLineY * 0.4)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    VStack(spacing: 22) {
                        ZStack {
                            PulsingRing(color: Color(red: 1.0, green: 0.4, blue: 0.3).opacity(0.15), maxRadius: RS.v(45), duration: 2.5)
                            
                            Circle()
                                .stroke(Color(red: 1.0, green: 0.4, blue: 0.3).opacity(0.4), lineWidth: 2)
                                .frame(width: RS.v(60), height: RS.v(60))
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: RS.font(40)))
                                .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.3))
                                .shadow(color: .red.opacity(0.5), radius: RS.v(8))
                        }
                        
                        // Typing header
                        TypingText(
                            fullText: "MISSION COMPLETE",
                            font: .system(size: RS.font(12), weight: .bold, design: .monospaced),
                            color: Color(red: 1.0, green: 0.5, blue: 0.3),
                            typingSpeed: 0.05
                        )
                        
                        Rectangle()
                            .fill(Color.red.opacity(0.3))
                            .frame(width: RS.v(250), height: 1)
                        
                        VStack(spacing: 10) {
                            Text("LESSON LEARNED")
                                .font(.system(size: RS.font(14), weight: .bold, design: .monospaced))
                                .foregroundColor(.yellow)
                            
                            Text("NOT Gate: The output is\nthe OPPOSITE of the input.")
                                .font(.system(size: RS.font(15), weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                            
                            Text("Input ON → Output OFF\nInput OFF → Output ON")
                                .font(.system(size: RS.font(13), weight: .medium, design: .monospaced))
                                .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.4).opacity(0.8))
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)
                        }
                        .padding(.horizontal, RS.v(20))
                        
                        Rectangle()
                            .fill(Color.red.opacity(0.2))
                            .frame(width: 200, height: 1)
                        
                        Button(action: {
                            onComplete()
                        }) {
                            Text("PROCEED TO MISSION 6")
                                .font(.system(size: RS.font(16), weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.horizontal, RS.v(30))
                                .padding(.vertical, RS.v(12))
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.8, green: 0.2, blue: 0.2),
                                            Color(red: 1.0, green: 0.4, blue: 0.2)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(RS.v(10))
                                .shadow(color: .red.opacity(0.5), radius: 8)
                        }
                    }
                    .padding(.vertical, RS.v(20))
                    
                    // Danger stripes at top and bottom of card
                    VStack {
                        HStack(spacing: RS.v(8)) {
                            ForEach(0..<12, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.red.opacity(0.15))
                                    .frame(width: RS.v(12), height: RS.v(3))
                                    .rotationEffect(.degrees(45))
                            }
                        }
                        .frame(width: RS.v(330))
                        .clipped()
                        Spacer()
                        HStack(spacing: RS.v(8)) {
                            ForEach(0..<12, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.red.opacity(0.15))
                                    .frame(width: RS.v(12), height: RS.v(3))
                                    .rotationEffect(.degrees(45))
                            }
                        }
                        .frame(width: RS.v(330))
                        .clipped()
                    }
                    .frame(width: RS.v(330), height: RS.v(400))
                    .allowsHitTesting(false)
                    
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
                ParticleBurstView(color: Color(red: 1.0, green: 0.5, blue: 0.3), particleCount: 30)
            }
        }
    }
    
    // MARK: - Success Trigger
    func triggerSuccess() {
        hasCompleted = true
        
        withAnimation(.easeInOut(duration: 1.2)) {
            theaterTransition = 1.0
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
            floatingParticles[i].x += CGFloat.random(in: -0.3...0.3)
            floatingParticles[i].opacity -= 0.007
        }
        floatingParticles.removeAll { $0.y < 0 || $0.opacity <= 0 }
        
        if Double.random(in: 0...1) < 0.25 {
            let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds ?? CGRect(x: 0, y: 0, width: 400, height: 900)
            let screenWidth = screenBounds.width
            let screenHeight = screenBounds.height
            let particleColor: Color = [
                Color(red: 1.0, green: 0.6, blue: 0.4),
                Color(red: 1.0, green: 0.6, blue: 0.4),
                Color(red: 1.0, green: 0.8, blue: 0.6),  // Peach
                Color(red: 1.0, green: 0.5, blue: 0.6)   // Rose
            ].randomElement()!
            let newParticle = Mission5Particle(
                id: UUID(),
                x: CGFloat.random(in: 0...screenWidth),
                y: screenHeight,
                size: CGFloat.random(in: 1...4.5),
                speed: CGFloat.random(in: 0.3...1.5),
                opacity: Double.random(in: 0.2...0.6),
                color: particleColor
            )
            floatingParticles.append(newParticle)
        }
    }
}

// MARK: - Particle Model
struct Mission5Particle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var speed: CGFloat
    var opacity: Double
    var color: Color = Color(red: 1.0, green: 0.6, blue: 0.4)
}

// MARK: - Regular Polygon Shape
struct RegularPolygon: Shape {
    let sides: Int
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        
        for i in 0..<sides {
            let angle = (Double(i) * (360.0 / Double(sides)) - 90) * .pi / 180
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    Mission5View(onComplete: {})
}
