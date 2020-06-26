//
//  PresentCardAnimator.swift
//  TestCustomTransitions
//
//  Created by 福山帆士 on 2020/06/25.
//  Copyright © 2020 福山帆士. All rights reserved.
//

import UIKit

final class PresentCardAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let params: Params
    
    private let presentAnimatorDuration: TimeInterval
    private let springAnimator: UIViewPropertyAnimator
    private var transitionDriver: PresentCardTransitionDriver?
    
    struct Params {
        let fromCardFrame: CGRect
        let fromCell: UICollectionViewCell
    }
    
    init(params: Params) {
        self.params = params
        self.springAnimator = PresentCardAnimator.createBaseSpringAnimator(params: params)
        self.presentAnimatorDuration = springAnimator.duration
        super.init()
    }
    // ここはpropert Animatorの設定(duration, timingを設定)
    private static func createBaseSpringAnimator(params: PresentCardAnimator.Params) -> UIViewPropertyAnimator {
        // damping
        let cardPositionY = params.fromCardFrame.minY
        let distanceToBounce = abs(params.fromCardFrame.minY)
        let extentToBouce = cardPositionY < 0 ? params.fromCardFrame.height : UIScreen.main.bounds.height
        let dampFactorInterval: CGFloat = 0.3
        let damping: CGFloat = 1.0 - dampFactorInterval * (distanceToBounce / extentToBouce)
        // duration
        let baselineDuration: TimeInterval = 0.5
        let maxDuration: TimeInterval = 0.9
        let duration: TimeInterval = baselineDuration + (maxDuration - baselineDuration) * TimeInterval(max(0, distanceToBounce) / UIScreen.main.bounds.height)
        // timing(ここでdampingを設定)
        let springTiming = UISpringTimingParameters(dampingRatio: damping, initialVelocity: .init(dx: 0, dy: 0))
        return UIViewPropertyAnimator(duration: duration, timingParameters: springTiming)
        
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return presentAnimatorDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        transitionDriver = PresentCardTransitionDriver(params: params, transitionContext: transitionContext, baseAnimator: springAnimator)
        interruptibleAnimator(using: transitionContext).startAnimation()
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        transitionDriver = nil
    }
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        return transitionDriver!.animator
    }
}
    // present animationの設定
    final class PresentCardTransitionDriver {
        let animator: UIViewPropertyAnimator
        init(params: PresentCardAnimator.Params, transitionContext: UIViewControllerContextTransitioning, baseAnimator: UIViewPropertyAnimator) {
            let ctx = transitionContext
            let container = ctx.containerView
            let screens: (home: HomeViewController, detail: DetailViewController) = (
                ctx.viewController(forKey: .from) as! HomeViewController,
                ctx.viewController(forKey: .to) as! DetailViewController
            )
            
            let detailView = ctx.view(forKey: .to)!
            let fromCardFram = params.fromCardFrame
            // 一時的なview
            let animatedContainerView = UIView()
            animatedContainerView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(animatedContainerView)
            do {
                let animatedContainerConstraints = [
                    animatedContainerView.widthAnchor.constraint(equalToConstant: container.bounds.width),
                    animatedContainerView.heightAnchor.constraint(equalToConstant: container.bounds.height),
                    animatedContainerView.centerXAnchor.constraint(equalTo: container.centerXAnchor)
                ]
                NSLayoutConstraint.activate(animatedContainerConstraints)
            }
            
            let animatedContainerVerticalConstraint: NSLayoutConstraint = {
                switch GlobalConstants.cardVerticalExpandingStyle {
                case .fromCenter:
                    return animatedContainerView.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: (fromCardFram.height / 2 + fromCardFram.minY) - container.bounds.height / 2)
                case .fromTop:
                    return animatedContainerView.topAnchor.constraint(equalTo: container.topAnchor, constant: fromCardFram.minY)
                }
            }()
            animatedContainerVerticalConstraint.isActive = true
            animatedContainerView.addSubview(detailView)
            detailView.translatesAutoresizingMaskIntoConstraints = false
            
            do {
                let verticalAnchor: NSLayoutConstraint = {
                    switch GlobalConstants.cardVerticalExpandingStyle {
                    case .fromCenter:
                        return detailView.centerYAnchor.constraint(equalTo: animatedContainerView.centerYAnchor)
                    case .fromTop:
                        return detailView.topAnchor.constraint(equalTo: animatedContainerView.topAnchor, constant: -1)
                    }
                }()
                let cardConstraints = [
                    verticalAnchor,
                    detailView.centerXAnchor.constraint(equalTo: animatedContainerView.centerXAnchor)
                ]
                NSLayoutConstraint.activate(cardConstraints)
            }
            
            let cardWidthConstraint = detailView.widthAnchor.constraint(equalToConstant: fromCardFram.width)
            let cardHeightConstraint = detailView.heightAnchor.constraint(equalToConstant: fromCardFram.height)
            NSLayoutConstraint.activate([cardWidthConstraint, cardHeightConstraint])
            
            params.fromCell.isHidden = true
            let topTemporaryFix = screens.detail.cardView.topAnchor.constraint(equalTo: detailView.topAnchor, constant: 0)
            topTemporaryFix.isActive = GlobalConstants.isEnabledWeirdTopInsetsFix
            
            container.layoutIfNeeded()
            
            
            // Animator container bouncing up
            func animateContainerBouncingUp() {
                // animatedContainerVerticalConstraint.constant = 0
                container.layoutIfNeeded()
            }
            
            // Animator cardDetail filling up the container
            func animatedCardDetailViewSizing() {
                cardWidthConstraint.constant = animatedContainerView.bounds.width
                cardHeightConstraint.constant = animatedContainerView.bounds.height
                
                container.layoutIfNeeded()
            }
            
            // Animator finish
            func completeEverything() {
                animatedContainerView.removeConstraints(animatedContainerView.constraints)
                animatedContainerView.removeFromSuperview()
                
                container.addSubview(detailView)
                detailView.removeConstraints([topTemporaryFix, cardWidthConstraint, cardHeightConstraint])
                detailView.edges(to: container, top: -1)
                ctx.completeTransition(true)
            }
            
            baseAnimator.addAnimations {
                animateContainerBouncingUp()
                
                let cardExpanding = UIViewPropertyAnimator(duration: baseAnimator.duration * 0.6, curve: .linear) {
                    animatedCardDetailViewSizing()
                }
                cardExpanding.startAnimation()
            }
            
            baseAnimator.addCompletion { (_) in
                completeEverything()
            }
            self.animator = baseAnimator
            
    }
}
