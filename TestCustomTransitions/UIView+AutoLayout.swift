//
//  UIView+AutoLayout.swift
//  TestCustomTransitions
//
//  Created by 福山帆士 on 2020/06/26.
//  Copyright © 2020 福山帆士. All rights reserved.
//

import UIKit
// UIViewの拡張
extension UIView {
    
    func edges(to view: UIView, top: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0, left: CGFloat = 0) {
        NSLayoutConstraint.activate([
            self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: left),
            self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: right),
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: top),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom)
        ])
    }
}
