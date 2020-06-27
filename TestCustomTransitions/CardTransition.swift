//
//  CardTransition.swift
//  TestCustomTransitions
//
//  Created by 福山帆士 on 2020/06/25.
//  Copyright © 2020 福山帆士. All rights reserved.
//

import UIKit

final class CardTransition: NSObject, UIViewControllerTransitioningDelegate {
    // Transition Delegate
    struct Params {
        let fromCardFrame: CGRect
        let fromCardWithoutTransform: CGRect // これはdesmiss時に使用
        let fromCell: UICollectionViewCell
    }
    
    let params: Params
    
    init(params: Params) {
        self.params = params
        super.init()
    }
    // Present Animation
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let params = PresentCardAnimator.Params.init(fromCardFrame: self.params.fromCardFrame, fromCell: self.params.fromCell)
        return PresentCardAnimator(params: params)
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CardPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
