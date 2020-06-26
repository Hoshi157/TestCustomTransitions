//
//  GlobalConstants.swift
//  TestCustomTransitions
//
//  Created by 福山帆士 on 2020/06/25.
//  Copyright © 2020 福山帆士. All rights reserved.
//

import UIKit

enum GlobalConstants {
    static let cardHighlightedFactor: CGFloat = 0.96
    static let statusBarAnimationDuration: TimeInterval = 0.4
    static let cardCornerRadius: CGFloat = 16
    static let dismissalAnimationDuration: TimeInterval = 0.6
    static let cardVerticalExpandingStyle: CardVerticalExpandingStyle = .fromTop
    static let isEnabledWeirdTopInsetsFix = true
    static let isEnabledDebugAnimationViews = false
    static let isEnabledTopSafeAreaInsetsFixOnCardDetailViewController = false
    static let isEnabledAllowsUserInteractionWhileHighlightingCard = true
    static let isEnabledDebugShowTimeTouch = true
}

extension GlobalConstants {
    enum CardVerticalExpandingStyle {
        
        case fromTop
        
        case fromCenter
    }
}
