import SwiftUI

struct IntroView: View {
    var onComplete: () -> Void
    
    // Animation States
    @State private var titleOpacity: Double = 0.0
    @State private var flashcardOpacity: Double = 0.0
    @State private var flashcardScale: CGFloat = 0.8
    @State private var showTitle: Bool = true
    
    // Flashlight Animation
    @State private var flashlightOffset: CGFloat = RS.v(-400)
    @State private var flashlightOpacity: Double = 0.0
    
    // Reveal Mask
    @State private var revealMaskWidth: CGFloat = 0.0
    
    // Flashcard Background Animations
    @State private var scanLineYOffset: CGFloat = RS.v(-300)
    @State private var borderGlow: Double = 0.5
    @State private var particleRotation: Double = 0
    @State private var gridOpacity: Double = 0.0
    @State private var glitchOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background (Black)
            Color.black.edgesIgnoringSafeArea(.all)
            
            // CRT scanline overlay (always visible for retro feel)
            CRTOverlay(lineSpacing: 4, opacity: 0.04)
                .edgesIgnoringSafeArea(.all)
            
            // MARK: - Background Effects (visible during flashcard)
            if flashcardOpacity > 0 {
                // Subtle circuit grid background
                GeometryReader { geometry in
                    ZStack {
                        // Vertical grid lines
                        ForEach(0..<Int(geometry.size.width / 30), id: \.self) { i in
                            Rectangle()
                                .fill(Color.cyan.opacity(0.05))
                                .frame(width: 1, height: geometry.size.height)
                                .position(x: CGFloat(i) * 30, y: geometry.size.height / 2)
                        }
                        // Horizontal grid lines
                        ForEach(0..<Int(geometry.size.height / 30), id: \.self) { i in
                            Rectangle()
                                .fill(Color.cyan.opacity(0.05))
                                .frame(width: geometry.size.width, height: 1)
                                .position(x: geometry.size.width / 2, y: CGFloat(i) * 30)
                        }
                        
                        // Floating particles
                        ForEach(0..<20, id: \.self) { i in
                            Circle()
                                .fill(Color.cyan.opacity(Double.random(in: 0.1...0.3)))
                                .frame(width: CGFloat.random(in: 2...5), height: CGFloat.random(in: 2...5))
                                .position(
                                    x: CGFloat.random(in: 0...geometry.size.width),
                                    y: CGFloat.random(in: 0...geometry.size.height)
                                )
                        }
                        
                        // Scanning Line
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .cyan.opacity(0.15), .clear]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width, height: 2)
                            .offset(y: scanLineYOffset)
                        
                        // Corner accents
                        ForEach(0..<4, id: \.self) { corner in
                            CornerAccentView()
                                .rotationEffect(.degrees(Double(corner) * 90))
                                .position(
                                    x: corner % 2 == 0 ? 40 : geometry.size.width - 40,
                                    y: corner < 2 ? 80 : geometry.size.height - 80
                                )
                        }
                    }
                }
                .opacity(gridOpacity)
                .edgesIgnoringSafeArea(.all)
                
                // Additional CRT overlay on flashcard bg
                CRTOverlay(lineSpacing: 3, opacity: 0.05)
                    .edgesIgnoringSafeArea(.all)
                    .opacity(gridOpacity)
            }
            
            // MARK: - Title Reveal
            if showTitle {
                VStack {
                    Spacer()
                    
                    ZStack {
                        // The Title (Hidden initially, revealed by mask)
                        Text("THE LAST CIRCUIT")
                            .font(.custom("CourierNew-Bold", size: RS.font(40)))
                            .foregroundColor(.white)
                            .shadow(color: .cyan, radius: RS.v(10))
                            .mask(
                                Rectangle()
                                    .frame(width: revealMaskWidth, height: RS.v(100))
                                    .offset(x: RS.v(-200) + revealMaskWidth/2)
                            )
                        
                        // The Flashlight Beam
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .white.opacity(0.8), .clear]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: RS.v(80), height: RS.v(80))
                            .blur(radius: RS.v(10))
                            .offset(x: flashlightOffset)
                            .opacity(flashlightOpacity)
                            .blendMode(.screen)
                    }
                    
                    Spacer()
                }
            }
            
            // MARK: - Flashcard (Technician Identity)
            if flashcardOpacity > 0 {
                VStack(spacing: RS.v(30)) {
                    ZStack {
                        // Outer glow
                        RoundedRectangle(cornerRadius: RS.v(22))
                            .fill(Color.cyan.opacity(0.1 * borderGlow))
                            .frame(width: RS.v(330), height: RS.v(520))
                            .blur(radius: RS.v(15))
                        
                        // Card background with gradient
                        RoundedRectangle(cornerRadius: RS.v(20))
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.05, green: 0.08, blue: 0.15),
                                        Color(red: 0.02, green: 0.02, blue: 0.08),
                                        Color(red: 0.05, green: 0.0, blue: 0.12)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: RS.v(320), height: RS.v(500))
                        
                        // Holographic animated border
                        HolographicBorder(
                            cornerRadius: RS.v(20),
                            width: RS.v(320),
                            height: RS.v(500)
                        )
                        
                        // Scan line across card
                        RoundedRectangle(cornerRadius: RS.v(20))
                            .fill(Color.clear)
                            .frame(width: RS.v(320), height: RS.v(500))
                            .overlay(
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.clear, .cyan.opacity(0.08), .clear]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(height: RS.v(80))
                                    .offset(y: scanLineYOffset * 0.5)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: RS.v(20)))
                        
                        VStack(spacing: RS.v(20)) {
                            // Typing-styled header
                            ZStack {
                                TypingText(
                                    fullText: "IDENTITY CONFIRMED",
                                    font: .custom("CourierNew-Bold", size: RS.font(22)),
                                    color: .green,
                                    typingSpeed: 0.06
                                )
                            }
                            
                            // Technician Image with frame
                            ZStack {
                                RoundedRectangle(cornerRadius: RS.v(10))
                                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                                    .frame(width: RS.v(160), height: RS.v(160))
                                
                                Image("LuminaMech")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: RS.v(150))
                                    .shadow(color: .cyan, radius: RS.v(10))
                            }
                            
                            // Divider line
                            Rectangle()
                                .fill(Color.cyan.opacity(0.3))
                                .frame(width: RS.v(250), height: 1)
                            
                            VStack(alignment: .center, spacing: RS.v(12)) {
                                Text("ROLE: Lumina Technician")
                                    .font(.custom("CourierNew-Bold", size: RS.font(18)))
                                    .foregroundColor(.white)
                                
                                Text("MISSION:")
                                    .font(.custom("CourierNew-Bold", size: RS.font(18)))
                                    .foregroundColor(.yellow)
                                
                                Text("Bring glory to the city\nthrough Logic Gates")
                                    .font(.custom("CourierNew", size: RS.font(15)))
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(RS.v(4))
                            }
                            
                            Button(action: {
                                onComplete()
                            }) {
                                Text("START MISSION 1")
                                    .font(.system(size: RS.font(20), weight: .bold, design: .monospaced))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, RS.v(40))
                                    .padding(.vertical, RS.v(12))
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.cyan, Color(red: 0.0, green: 0.9, blue: 0.8)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(RS.v(10))
                                    .shadow(color: .cyan.opacity(0.5), radius: RS.v(8))
                            }
                        }
                    }
                }
                .scaleEffect(flashcardScale)
                .opacity(flashcardOpacity)
            }
        }
        .onAppear {
            startAnimationSequence()
        }
    }
    
    func startAnimationSequence() {
        // 1. Flashlight Sweep & Reveal
        let duration = 2.5
        
        withAnimation(.easeOut(duration: 0.5)) {
            flashlightOpacity = 1.0
        }
        
        withAnimation(.linear(duration: duration).delay(0.5)) {
            flashlightOffset = RS.v(400)
            revealMaskWidth = RS.v(600)
        }
        
        // Fade out flashlight beam
        withAnimation(.easeOut(duration: 0.5).delay(0.5 + duration)) {
            flashlightOpacity = 0.0
        }
        
        // 2. Hold Title -> Hide -> Show Flashcard
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                titleOpacity = 0.0
                showTitle = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Show flashcard with spring
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    flashcardOpacity = 1.0
                    flashcardScale = 1.0
                }
                
                // Fade in grid background
                withAnimation(.easeIn(duration: 1.0)) {
                    gridOpacity = 1.0
                }
                
                // Start continuous animations
                startFlashcardAnimations()
            }
        }
    }
    
    func startFlashcardAnimations() {
        // Scanning line loop
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            scanLineYOffset = RS.v(300)
        }
        
        // Border glow pulse
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            borderGlow = 1.0
        }
        
        // Particle rotation (subtle)
        withAnimation(.linear(duration: 20.0).repeatForever(autoreverses: false)) {
            particleRotation = 360
        }
        
        // Glitch effect (periodic jitter)
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
}

// Small corner accent decoration
struct CornerAccentView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.cyan.opacity(0.3))
                .frame(width: RS.v(20), height: RS.v(2))
                .offset(x: RS.v(10))
            Rectangle()
                .fill(Color.cyan.opacity(0.3))
                .frame(width: RS.v(2), height: RS.v(20))
                .offset(y: RS.v(10))
        }
    }
}

#Preview {
    IntroView(onComplete: {})
}
