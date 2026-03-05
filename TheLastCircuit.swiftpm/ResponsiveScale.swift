import SwiftUI

/// Provides responsive scaling factors based on screen dimensions.
/// Reference device: iPhone 14 Pro (393 × 852)
/// On iPad (e.g. 1024 × 1366), scale factors are larger so UI elements grow proportionally.
struct RS {
    /// Gets the current screen bounds using the active window scene
    private static var screenBounds: CGRect {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return scene.screen.bounds
        }
        return CGRect(x: 0, y: 0, width: 393, height: 852)
    }
    
    /// Scale factor based on screen width (reference: 393pt iPhone)
    static var sw: CGFloat {
        screenBounds.width / 393.0
    }
    
    /// Scale factor based on screen height (reference: 852pt iPhone)
    static var sh: CGFloat {
        screenBounds.height / 852.0
    }
    
    /// Minimum of width/height scale — safe for elements that shouldn't overshoot
    static var s: CGFloat {
        min(sw, sh)
    }
    
    /// Font scaling — capped at 2x to avoid absurdly large text
    static var f: CGFloat {
        min(s, 2.0)
    }
    
    /// Scale a point value proportionally to screen width
    static func w(_ value: CGFloat) -> CGFloat {
        value * sw
    }
    
    /// Scale a point value proportionally to screen height
    static func h(_ value: CGFloat) -> CGFloat {
        value * sh
    }
    
    /// Scale a value proportionally (min of w/h), clamped to avoid extremes
    static func v(_ value: CGFloat) -> CGFloat {
        value * s
    }
    
    /// Scale a font size — uses capped scaling
    static func font(_ size: CGFloat) -> CGFloat {
        size * f
    }
    
    /// Whether the current device is iPad-class (width > 700pt)
    static var isIPad: Bool {
        screenBounds.width > 700
    }
}

