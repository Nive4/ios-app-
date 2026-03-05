import SwiftUI
import Combine

struct Mission6View: View {
    var onComplete: () -> Void
    
    // NOR Gate: 3 power conduits, all start connected (ON)
    // Player must disconnect ALL to restore power (NOR: output ON only when ALL inputs OFF)
    @State private var conduit1On: Bool = true
    @State private var conduit2On: Bool = true
    @State private var conduit3On: Bool = true
    
    // Animation States
    @State private var pulseOpacity: Double = 0.5
    @State private var hintGlow: Double = 0.6
    @State private var showFlashCard: Bool = false
    @State private var flashCardOpacity: Double = 0.0
    @State private var flashCardScale: CGFloat = 0.8
    @State private var successFlash: Double = 0.0
    @State private var cathedralTransition: Double = 0.0
    @State private var scanLineY: CGFloat = -300
    @State private var borderGlow: Double = 0.5
    @State private var glitchOffset: CGFloat = 0
    @State private var gridOpacity: Double = 0.0
    @State private var hasCompleted: Bool = false
    @State private var showBurst: Bool = false
    @State private var stainedGlassHue: Double = 0.58
    @State private var candleFlicker: Double = 0.7
    @State private var flowPhase: CGFloat = 0.0
    
    // Floating particles (candlelight)
    @State private var floatingParticles: [Mission6Particle] = []
    let particleTimer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
    let flowTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    // NOR Gate: output ON only when ALL inputs are OFF
    var norResult: Bool {
        !conduit1On && !conduit2On && !conduit3On
    }
    
    // Count of active conduits
    var activeCount: Int {
        [conduit1On, conduit2On, conduit3On].filter { $0 }.count
    }
    
    // Deep blue / silver palette
    let accentColor = Color(red: 0.35, green: 0.55, blue: 0.95)
    let silverColor = Color(red: 0.75, green: 0.78, blue: 0.85)
    let stainedGold = Color(red: 0.95, green: 0.8, blue: 0.4)
    
    var body: some View {
        ZStack {
            // MARK: - 1. Deep Gothic Night Background
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.01, green: 0.02, blue: 0.06),
                Color(red: 0.03, green: 0.04, blue: 0.12),
                Color(red: 0.02, green: 0.03, blue: 0.10),
                Color(red: 0.01, green: 0.01, blue: 0.04)
            ]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            
            // MARK: - 2. Stained Glass Grid (shifting hue)
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<Int(geometry.size.width / 50), id: \.self) { i in
                        Rectangle()
                            .fill(Color(hue: stainedGlassHue, saturation: 0.6, brightness: 0.5).opacity(0.025))
                            .frame(width: 1, height: geometry.size.height)
                            .position(x: CGFloat(i) * 50, y: geometry.size.height / 2)
                    }
                    ForEach(0..<Int(geometry.size.height / 50), id: \.self) { i in
                        Rectangle()
                            .fill(Color(hue: stainedGlassHue, saturation: 0.6, brightness: 0.5).opacity(0.025))
                            .frame(width: geometry.size.width, height: 1)
                            .position(x: geometry.size.width / 2, y: CGFloat(i) * 50)
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .opacity(gridOpacity)
            
            // MARK: - 3. Candlelight Particles
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
            
            // MARK: - 4. Stars
            GeometryReader { geometry in
                ForEach(0..<40, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.1...0.35)))
                        .frame(width: CGFloat.random(in: 1...2.5), height: CGFloat.random(in: 1...2.5))
                        .position(
                            x: CGFloat(i * 37 % Int(geometry.size.width)),
                            y: CGFloat.random(in: 0...geometry.size.height * 0.25)
                        )
                }
            }
            
            // MARK: - 5. Main Content
            GeometryReader { geo in
                let screenH = geo.size.height
                let screenW = geo.size.width
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 8) {
                        // Mission Label
                        Text("MISSION 6 — NOR GATE")
                            .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                            .foregroundColor(accentColor.opacity(0.7))
                            .padding(.top, 8)
                        
                        // Hint Banner
                        hintBanner(width: screenW)
                        
                        // Cathedral Image
                        cathedralImage(width: screenW, height: screenH * 0.30)
                            .padding(.top, 4)
                        
                        // NOR Gate Diagram with live state
                        norGateDiagram(width: screenW)
                            .padding(.vertical, 4)
                        
                        // 3 Power Conduits
                        conduitsView(width: screenW, height: screenH * 0.18)
                        
                        // Live Truth Table
                        truthTableView(width: screenW)
                            .padding(.vertical, 4)
                        
                        // Status indicator
                        if !hasCompleted {
                            statusIndicator
                        }
                        
                        Spacer().frame(height: 8)
                    }
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
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                stainedGlassHue = 0.72
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                candleFlicker = 1.0
            }
        }
        .onReceive(particleTimer) { _ in
            updateParticles()
        }
        .onReceive(flowTimer) { _ in
            flowPhase += 0.08
            if flowPhase > 2 * .pi { flowPhase -= 2 * .pi }
        }
        .onChange(of: norResult, perform: { newValue in
            if newValue && !hasCompleted {
                triggerSuccess()
            }
        })
    }
    
    // MARK: - Hint Banner
    func hintBanner(width: CGFloat) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "cross.fill")
                    .foregroundColor(stainedGold)
                    .font(.system(size: 13))
                Text("HINT")
                    .font(.system(size: RS.font(12), weight: .bold, design: .monospaced))
                    .foregroundColor(stainedGold)
            }
            
            Text("Power surges are overloading")
                .font(.system(size: RS.font(11), weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Text("the cathedral's old wiring!")
                .font(.system(size: RS.font(11), weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
            
            Text("Disconnect ALL conduits to reset")
                .font(.system(size: RS.font(10), weight: .bold, design: .monospaced))
                .foregroundColor(accentColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, RS.v(8))
        .frame(maxWidth: width - 40)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(accentColor.opacity(hintGlow * 0.4), lineWidth: 1.5)
                )
        )
        .shadow(color: accentColor.opacity(hintGlow * 0.2), radius: RS.v(10))
    }
    
    // MARK: - Cathedral Image
    func cathedralImage(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            // Dim glow behind dark cathedral
            if cathedralTransition < 0.5 {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                accentColor.opacity(0.04),
                                Color(red: 0.2, green: 0.2, blue: 0.4).opacity(0.03),
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
            
            // Dark cathedral
            Image("CathedralDark")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.88, height: height)
                .clipped()
                .opacity(1.0 - cathedralTransition)
            
            // Lit cathedral
            Image("CathedralLit")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.88, height: height)
                .clipped()
                .opacity(cathedralTransition)
            
            // Golden glow when lit
            if cathedralTransition > 0.5 {
                Image("CathedralLit")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width * 0.88, height: height)
                    .clipped()
                    .blur(radius: RS.v(20))
                    .opacity(0.35 * cathedralTransition)
                    .blendMode(.screen)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            accentColor.opacity(0.15),
                            silverColor.opacity(0.08),
                            accentColor.opacity(0.15)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: norResult ? stainedGold.opacity(0.5) : accentColor.opacity(0.04), radius: RS.v(20))
    }
    
    // MARK: - NOR Gate Diagram
    func norGateDiagram(width: CGFloat) -> some View {
        HStack(spacing: 8) {
            // 3 Inputs
            VStack(spacing: 4) {
                Text("INPUTS")
                    .font(.system(size: RS.font(7), weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
                
                ForEach(0..<3, id: \.self) { i in
                    let isOn = [conduit1On, conduit2On, conduit3On][i]
                    Circle()
                        .fill(isOn ? Color.red.opacity(0.7) : Color.green.opacity(0.5))
                        .frame(width: 8, height: 8)
                        .shadow(color: isOn ? .red.opacity(0.5) : .green.opacity(0.5), radius: 2)
                }
            }
            
            // Arrow
            Image(systemName: "arrow.right")
                .font(.system(size: RS.font(12)))
                .foregroundColor(.white.opacity(0.3))
            
            // NOR Gate symbol
            ZStack {
                // Gothic arch shape using rounded rect
                RoundedRectangle(cornerRadius: 8)
                    .stroke(accentColor.opacity(0.5), lineWidth: 1.5)
                    .frame(width: 50, height: 28)
                
                Text("NOR")
                    .font(.system(size: RS.font(9), weight: .bold, design: .monospaced))
                    .foregroundColor(accentColor)
            }
            
            // Arrow
            Image(systemName: "arrow.right")
                .font(.system(size: RS.font(12)))
                .foregroundColor(.white.opacity(0.3))
            
            // Output
            VStack(spacing: 2) {
                Text("OUTPUT")
                    .font(.system(size: RS.font(7), weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
                Circle()
                    .fill(norResult ? Color.green : Color.red.opacity(0.6))
                    .frame(width: 10, height: 10)
                    .shadow(color: norResult ? .green : .red, radius: 3)
                Text(norResult ? "ON" : "OFF")
                    .font(.system(size: RS.font(8), weight: .bold, design: .monospaced))
                    .foregroundColor(norResult ? .green : .red)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, RS.v(8))
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(accentColor.opacity(0.12), lineWidth: 1)
                )
        )
    }
    
    // MARK: - 3 Power Conduits
    func conduitsView(width: CGFloat, height: CGFloat) -> some View {
        HStack(spacing: 0) {
            conduitView(
                label: "Nave\nConduit",
                icon: "bolt.fill",
                isConnected: conduit1On,
                cableColor: Color(red: 0.3, green: 0.6, blue: 1.0),
                height: height,
                action: {
                    if !hasCompleted {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
                            conduit1On.toggle()
                        }
                    }
                }
            )
            .frame(width: width * 0.30)
            
            conduitView(
                label: "Bell\nTower",
                icon: "bell.fill",
                isConnected: conduit2On,
                cableColor: Color(red: 0.5, green: 0.4, blue: 1.0),
                height: height,
                action: {
                    if !hasCompleted {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
                            conduit2On.toggle()
                        }
                    }
                }
            )
            .frame(width: width * 0.30)
            
            conduitView(
                label: "Crypt\nPower",
                icon: "flame.fill",
                isConnected: conduit3On,
                cableColor: Color(red: 0.4, green: 0.7, blue: 0.9),
                height: height,
                action: {
                    if !hasCompleted {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
                            conduit3On.toggle()
                        }
                    }
                }
            )
            .frame(width: width * 0.30)
        }
    }
    
    // MARK: - Single Conduit View
    func conduitView(label: String, icon: String, isConnected: Bool, cableColor: Color, height: CGFloat, action: @escaping () -> Void) -> some View {
        VStack(spacing: 5) {
            Text(label)
                .font(.system(size: RS.font(10), weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: action) {
                ZStack {
                    // Glow behind cable
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            isConnected ?
                            cableColor.opacity(0.15) :
                            Color.gray.opacity(0.05)
                        )
                        .frame(width: height * 0.55, height: height * 0.7)
                        .blur(radius: RS.v(10))
                    
                    // Cable body
                    VStack(spacing: 0) {
                        // Top connector
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isConnected ? cableColor : Color.gray.opacity(0.3))
                            .frame(width: 14, height: 18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                            )
                        
                        // Cable line
                        if isConnected {
                            // Connected: solid flowing cable
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            cableColor.opacity(0.4 + 0.3 * Foundation.sin(Double(flowPhase))),
                                            cableColor.opacity(0.8),
                                            cableColor.opacity(0.4 + 0.3 * Foundation.sin(Double(flowPhase) + 2)),
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 6, height: height * 0.3)
                                .shadow(color: cableColor.opacity(0.6), radius: 4)
                        } else {
                            // Disconnected: broken cable with gap
                            VStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 6, height: height * 0.1)
                                
                                Image(systemName: "xmark")
                                    .font(.system(size: RS.font(10), weight: .bold))
                                    .foregroundColor(.red.opacity(0.5))
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 6, height: height * 0.1)
                            }
                        }
                        
                        // Bottom connector
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isConnected ? cableColor : Color.gray.opacity(0.3))
                            .frame(width: 14, height: 18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                            )
                    }
                    
                    // Spark at connection points when connected
                    if isConnected {
                        Circle()
                            .fill(Color.white)
                            .frame(width: RS.v(4), height: RS.v(4))
                            .opacity(candleFlicker * 0.7)
                            .offset(y: -(height * 0.2))
                            .blur(radius: 1)
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: RS.v(4), height: RS.v(4))
                            .opacity(candleFlicker * 0.7)
                            .offset(y: height * 0.2)
                            .blur(radius: 1)
                        
                        // Electric arc along cable
                        ElectricArc(segments: 4, amplitude: RS.v(2))
                            .stroke(cableColor.opacity(0.35), lineWidth: 1)
                            .frame(width: RS.v(14), height: height * 0.2)
                    }
                    
                    // Icon overlay
                    Image(systemName: icon)
                        .font(.system(size: RS.font(12)))
                        .foregroundColor(isConnected ? cableColor.opacity(0.8) : .gray.opacity(0.3))
                        .offset(x: RS.v(20))
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Status text
            Text(isConnected ? "LINKED" : "SEVERED")
                .font(.system(size: RS.font(9), weight: .bold, design: .monospaced))
                .foregroundColor(isConnected ? .red.opacity(0.8) : .green)
                .shadow(color: isConnected ? .red.opacity(0.3) : .green.opacity(0.4), radius: 3)
        }
    }
    
    // MARK: - Live Truth Table
    func truthTableView(width: CGFloat) -> some View {
        VStack(spacing: 4) {
            Text("NOR TRUTH TABLE")
                .font(.system(size: RS.font(8), weight: .bold, design: .monospaced))
                .foregroundColor(silverColor.opacity(0.6))
            
            // Header row
            HStack(spacing: 0) {
                truthCell(text: "A", isHeader: true)
                truthCell(text: "B", isHeader: true)
                truthCell(text: "C", isHeader: true)
                Rectangle().fill(silverColor.opacity(0.2)).frame(width: 1, height: 16)
                truthCell(text: "OUT", isHeader: true)
            }
            
            // Data rows
            let rows: [(Bool, Bool, Bool)] = [
                (false, false, false),
                (true, false, false),
                (false, true, false),
                (false, false, true),
                (true, true, false),
                (true, false, true),
                (false, true, true),
                (true, true, true)
            ]
            
            ForEach(0..<rows.count, id: \.self) { i in
                let row = rows[i]
                let norOut = !(row.0 || row.1 || row.2)
                let isCurrent = (row.0 == conduit1On && row.1 == conduit2On && row.2 == conduit3On)
                
                HStack(spacing: 0) {
                    truthCell(text: row.0 ? "1" : "0", isHeader: false, isActive: row.0)
                    truthCell(text: row.1 ? "1" : "0", isHeader: false, isActive: row.1)
                    truthCell(text: row.2 ? "1" : "0", isHeader: false, isActive: row.2)
                    Rectangle().fill(silverColor.opacity(0.1)).frame(width: 1, height: 14)
                    truthCell(text: norOut ? "1" : "0", isHeader: false, isActive: norOut)
                }
                .padding(.vertical, 1)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(isCurrent ? accentColor.opacity(0.15) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(isCurrent ? accentColor.opacity(0.4) : Color.clear, lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, RS.v(8))
        .frame(maxWidth: width - 60)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(silverColor.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    func truthCell(text: String, isHeader: Bool, isActive: Bool = false) -> some View {
        Text(text)
            .font(.system(size: isHeader ? 8 : 9, weight: isHeader ? .bold : .medium, design: .monospaced))
            .foregroundColor(
                isHeader ? silverColor.opacity(0.7) :
                (isActive ? Color.green.opacity(0.9) : Color.red.opacity(0.5))
            )
            .frame(width: 32, height: isHeader ? 16 : 14)
    }
    
    // MARK: - Status Indicator
    var statusIndicator: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(activeCount > 0 ? Color.red : Color.green)
                .frame(width: 8, height: 8)
                .opacity(pulseOpacity)
            Text(activeCount == 0 ? "ALL CLEAR — RESETTING..." :
                 "\(activeCount) CONDUIT\(activeCount > 1 ? "S" : "") STILL SURGING")
                .font(.system(size: RS.font(10), weight: .bold, design: .monospaced))
                .foregroundColor(activeCount > 0 ? .red.opacity(0.7) : .green.opacity(0.8))
        }
    }
    
    // MARK: - Completion Flashcard
    var completionFlashcard: some View {
        ZStack {
            Color.black.opacity(0.85)
                .edgesIgnoringSafeArea(.all)
            
            // Background grid
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<Int(geometry.size.width / 30), id: \.self) { i in
                        Rectangle()
                            .fill(accentColor.opacity(0.025))
                            .frame(width: 1, height: geometry.size.height)
                            .position(x: CGFloat(i) * 30, y: geometry.size.height / 2)
                    }
                    ForEach(0..<Int(geometry.size.height / 30), id: \.self) { i in
                        Rectangle()
                            .fill(accentColor.opacity(0.025))
                            .frame(width: geometry.size.width, height: 1)
                            .position(x: geometry.size.width / 2, y: CGFloat(i) * 30)
                    }
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, accentColor.opacity(0.08), .clear]),
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
                        .fill(accentColor.opacity(0.06 * borderGlow))
                        .frame(width: 340, height: 440)
                        .blur(radius: RS.v(15))
                    
                    // Card background
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.03, green: 0.04, blue: 0.10),
                                    Color(red: 0.02, green: 0.02, blue: 0.06),
                                    Color(red: 0.04, green: 0.03, blue: 0.08)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: RS.v(330), height: RS.v(420))
                    
                    // Animated border
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    accentColor.opacity(borderGlow),
                                    stainedGold.opacity(0.3),
                                    accentColor.opacity(borderGlow)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                        .frame(width: RS.v(330), height: RS.v(420))
                    
                    // Scanline overlay
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.clear)
                        .frame(width: RS.v(330), height: RS.v(420))
                        .overlay(
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.clear, accentColor.opacity(0.05), .clear]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: 60)
                                .offset(y: scanLineY * 0.4)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    VStack(spacing: 18) {
                        // Success icon with pulsing glow
                        ZStack {
                            PulsingRing(color: accentColor.opacity(0.12), maxRadius: RS.v(45), duration: 2.5)
                            PulsingRing(color: stainedGold.opacity(0.08), maxRadius: RS.v(38), duration: 3.5)
                            
                            Circle()
                                .stroke(accentColor.opacity(0.4), lineWidth: 2)
                                .frame(width: RS.v(60), height: RS.v(60))
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: RS.font(40)))
                                .foregroundColor(accentColor)
                                .shadow(color: accentColor.opacity(0.5), radius: RS.v(8))
                        }
                        
                        // Typing header
                        TypingText(
                            fullText: "MISSION COMPLETE",
                            font: .system(size: RS.font(12), weight: .bold, design: .monospaced),
                            color: accentColor,
                            typingSpeed: 0.05
                        )
                        
                        Rectangle()
                            .fill(accentColor.opacity(0.3))
                            .frame(width: RS.v(250), height: 1)
                        
                        VStack(spacing: 10) {
                            Text("LESSON LEARNED")
                                .font(.system(size: RS.font(14), weight: .bold, design: .monospaced))
                                .foregroundColor(stainedGold)
                            
                            Text("NOR Gate: Output is ON only\nwhen ALL inputs are OFF.")
                                .font(.system(size: RS.font(15), weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                            
                            Text("Any input ON → Output OFF\nAll inputs OFF → Output ON")
                                .font(.system(size: RS.font(13), weight: .medium, design: .monospaced))
                                .foregroundColor(accentColor.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)
                            
                            Text("NOR = NOT + OR combined!")
                                .font(.system(size: RS.font(11), weight: .bold, design: .monospaced))
                                .foregroundColor(stainedGold.opacity(0.7))
                        }
                        .padding(.horizontal, RS.v(20))
                        
                        Rectangle()
                            .fill(accentColor.opacity(0.2))
                            .frame(width: 200, height: 1)
                        
                        Button(action: {
                            onComplete()
                        }) {
                            Text("RESTORE THE GLORY")
                                .font(.system(size: RS.font(16), weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.horizontal, RS.v(30))
                                .padding(.vertical, RS.v(12))
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            accentColor,
                                            Color(red: 0.5, green: 0.6, blue: 1.0)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(RS.v(10))
                                .shadow(color: accentColor.opacity(0.5), radius: 8)
                        }
                    }
                    .padding(.vertical, RS.v(15))
                    
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
                ParticleBurstView(color: accentColor, particleCount: 35)
            }
        }
    }
    
    // MARK: - Success Trigger
    func triggerSuccess() {
        hasCompleted = true
        
        withAnimation(.easeInOut(duration: 1.2)) {
            cathedralTransition = 1.0
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
    
    // MARK: - Floating Particles (Candlelight)
    func updateParticles() {
        for i in floatingParticles.indices {
            floatingParticles[i].y -= floatingParticles[i].speed
            floatingParticles[i].x += CGFloat.random(in: -0.5...0.5)
            floatingParticles[i].opacity -= 0.006
        }
        floatingParticles.removeAll { $0.y < 0 || $0.opacity <= 0 }
        
        if Double.random(in: 0...1) < 0.25 {
            let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds ?? CGRect(x: 0, y: 0, width: 400, height: 900)
            let screenWidth = screenBounds.width
            let screenHeight = screenBounds.height
            let particleColor: Color = [
                Color(red: 1.0, green: 0.85, blue: 0.4),
                Color(red: 1.0, green: 0.85, blue: 0.4),
                Color(red: 1.0, green: 0.7, blue: 0.3),   // Amber
                Color(red: 1.0, green: 0.95, blue: 0.7)   // Warm white
            ].randomElement()!
            let newParticle = Mission6Particle(
                id: UUID(),
                x: CGFloat.random(in: 0...screenWidth),
                y: screenHeight,
                size: CGFloat.random(in: 1.5...5),
                speed: CGFloat.random(in: 0.3...1.3),
                opacity: Double.random(in: 0.25...0.65),
                color: particleColor
            )
            floatingParticles.append(newParticle)
        }
    }
}

// MARK: - Particle Model
struct Mission6Particle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var speed: CGFloat
    var opacity: Double
    var color: Color = Color(red: 1.0, green: 0.85, blue: 0.4)
}

#Preview {
    Mission6View(onComplete: {})
}
