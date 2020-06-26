//
//  CardPresentationController.swift
//  TestCustomTransitions
//
//  Created by 福山帆士 on 2020/06/26.
//  Copyright © 2020 福山帆士. All rights reserved.
//

import UIKit
// カスタムモーダルクラス
class CardPresentationController: UIPresentationController {

    private lazy var blurView = UIVisualEffectView(effect: nil)
    
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    override func presentationTransitionWillBegin() {
        let container = containerView!
        blurView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(blurView)
        blurView.edges(to: container)
        blurView.alpha = 0.0
        
        presentingViewController.transitionCoordinator!.animate(alongsideTransition: { (ctx) in
            UIView.animate(withDuration: 0.5, animations: {
                self.blurView.effect = UIBlurEffect(style: .light)
                self.blurView.alpha = 1
            })
        }) {(ctx) in }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        presentingViewController.endAppearanceTransition()
    }
}
