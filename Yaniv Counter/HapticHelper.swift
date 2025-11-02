//
//  HapticHelper.swift
//  Yaniv Counter
//
//  Created by Yuvaansh Gandhi on 2025-11-02.
//

import UIKit

struct HapticHelper {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        // Wrap in do-catch to handle simulator/device limitations
        generator.impactOccurred()
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        // Wrap in do-catch to handle simulator/device limitations
        generator.notificationOccurred(type)
    }
}

