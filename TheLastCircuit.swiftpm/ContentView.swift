import SwiftUI

enum AppState {
    
    case landing
    case intro
    case game
    case mission2
    case mission3
    case mission4
    case mission5
    case mission6
    case glory
}

struct ContentView: View {
    @State private var appState: AppState = .landing
    
    var body: some View {
        ZStack {
            switch appState {
            case .landing:
                LandingPageView(onStart: {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        appState = .intro
                    }
                })
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            case .intro:
                IntroView(onComplete: {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        appState = .game
                    }
                })
                .transition(.opacity)
            case .game:
                GameView(onComplete: {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        appState = .mission2
                    }
                })
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            case .mission2:
                Mission2View(onComplete: {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        appState = .mission3
                    }
                })
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            case .mission3:
                Mission3View(onComplete: {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        appState = .mission4
                    }
                })
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            case .mission4:
                Mission4View(onComplete: {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        appState = .mission5
                    }
                })
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            case .mission5:
                Mission5View(onComplete: {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        appState = .mission6
                    }
                })
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            case .mission6:
                Mission6View(onComplete: {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        appState = .glory
                    }
                })
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            case .glory:
                GloryView()
                    .transition(.opacity.combined(with: .scale(scale: 1.05)))
            }
        }
        .animation(.easeInOut(duration: 0.6), value: appState)
    }
}

#Preview {
    ContentView()
}

