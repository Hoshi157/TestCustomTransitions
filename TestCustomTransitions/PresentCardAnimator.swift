//
//  PresentCardAnimator.swift
//  TestCustomTransitions
//
//  Created by 福山帆士 on 2020/06/25.
//  Copyright © 2020 福山帆士. All rights reserved.
//

import UIKit
//　Custom Animator
final class PresentCardAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let params: Params
    
    private let presentAnimatorDuration: TimeInterval
    private let springAnimator: UIViewPropertyAnimator
    private var transitionDriver: PresentCardTransitionDriver?
    // 初期値　セルの実体、大きさ
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
    // ここはproperty Animatorの設定(duration, timingを設定)
    private static func createBaseSpringAnimator(params: PresentCardAnimator.Params) -> UIViewPropertyAnimator {
        // damping
        let cardPositionY = params.fromCardFrame.minY // セルの最小Y(一番上)
        let distanceToBounce = abs(params.fromCardFrame.minY) // バウンドする距離
        // セルが上にあればあるほどdampingが大きくなる
        let extentToBouce = cardPositionY < 0 ? params.fromCardFrame.height : UIScreen.main.bounds.height
        let dampFactorInterval: CGFloat = 0.3
        // extentToBouceが大きければバウンドが大きくなる
        let damping: CGFloat = 1.0 - dampFactorInterval * (distanceToBounce / extentToBouce)
        // duration
        let baselineDuration: TimeInterval = 0.5
        let maxDuration: TimeInterval = 0.9
        // セルがUIScreenの上より遠ければdurationが加算
        let duration: TimeInterval = baselineDuration + (maxDuration - baselineDuration) * TimeInterval(max(0, distanceToBounce) / UIScreen.main.bounds.height)
        // timing(ここでdampingを設定)   UISpringTimigPrameters(バネ効果の設定)
        let springTiming = UISpringTimingParameters(dampingRatio: damping, initialVelocity: .init(dx: 0, dy: 0))
        return UIViewPropertyAnimator(duration: duration, timingParameters: springTiming)
        
    }
    // Duration
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return presentAnimatorDuration
    }
    // Animation move
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        transitionDriver = PresentCardTransitionDriver(params: params, transitionContext: transitionContext, baseAnimator: springAnimator)
        interruptibleAnimator(using: transitionContext).startAnimation()
    }
    // Animation　end
    func animationEnded(_ transitionCompleted: Bool) {
        transitionDriver = nil
    }
    // Animator Custom
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        return transitionDriver!.animator
    }
}
    // present animationの設定
    final class PresentCardTransitionDriver {
        let animator: UIViewPropertyAnimator
        init(params: PresentCardAnimator.Params, transitionContext: UIViewControllerContextTransitioning, baseAnimator: UIViewPropertyAnimator) {
            let ctx = transitionContext
            let container = ctx.containerView // Animation中のsuperView
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
            // animatedContainerViewをcontainerに合わせている
            do {
                let animatedContainerConstraints = [
                    animatedContainerView.widthAnchor.constraint(equalToConstant: container.bounds.width),
                    animatedContainerView.heightAnchor.constraint(equalToConstant: container.bounds.height),
                    animatedContainerView.centerXAnchor.constraint(equalTo: container.centerXAnchor)
                ]
                NSLayoutConstraint.activate(animatedContainerConstraints)
            }
            // topAnchorをconstantにてずらしてsizingした時にanimationするようにしている(広がるようなアニメーションになり見栄えが悪い)
            let animatedContainerVerticalConstraint = animatedContainerView.topAnchor.constraint(equalTo: container.topAnchor, constant: fromCardFram.minY)
            animatedContainerVerticalConstraint.isActive = true
            
            // present先の画面のaddView
            animatedContainerView.addSubview(detailView)
            detailView.translatesAutoresizingMaskIntoConstraints = false
            // detailviewのLayoutを合わせる
            do {
                let verticalAnchor = detailView.topAnchor.constraint(equalTo: animatedContainerView.topAnchor, constant: -1)
                let cardConstraints = [
                    verticalAnchor,
                    detailView.centerXAnchor.constraint(equalTo: animatedContainerView.centerXAnchor)
                ]
                NSLayoutConstraint.activate(cardConstraints)
            }
            
            let cardWidthConstraint = detailView.widthAnchor.constraint(equalToConstant: fromCardFram.width)
            let cardHeightConstraint = detailView.heightAnchor.constraint(equalToConstant: fromCardFram.height)
            NSLayoutConstraint.activate([cardWidthConstraint, cardHeightConstraint])
            
            params.fromCell.isHidden = true // layoutを合わせた時点でCellを削除
            container.layoutIfNeeded() // 最後にlayoutを整える
            
            // Animator container bouncing up
            func animateContainerBouncingUp() {
                // constantを0にすることでbouncing
                animatedContainerVerticalConstraint.constant = 0
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
                // animatedContainerViewを削除
                animatedContainerView.removeConstraints(animatedContainerView.constraints)
                animatedContainerView.removeFromSuperview()
                // detailViewを再度追加
                container.addSubview(detailView)
                // layoutをもう一度設定
                detailView.removeConstraints([cardWidthConstraint, cardHeightConstraint])
                detailView.edges(to: container, top: -1)
                ctx.completeTransition(true)
            }
            // Animation 部分
            baseAnimator.addAnimations {
                animateContainerBouncingUp()
                // ここのderationは調整？？？
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
