//
//  HomeViewController.swift
//  TestCustomTransitions
//
//  Created by 福山帆士 on 2020/06/25.
//  Copyright © 2020 福山帆士. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var transition: CardTransition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        if let layout = collectionView.collectionViewLayout  as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 20
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = .init(top: 20, left: 0, bottom: 64, right: 0)
        }
        // Do any additional setup after loading the view.
    }
}

extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "Detail") as! DetailViewController
        let cell = collectionView.cellForItem(at: indexPath)!
        let currentCellFrame = cell.layer.presentation()!.frame
        let cardPresentationFramOnScreen = cell.superview!.convert(currentCellFrame, to: nil)
        
        let cardFrameWithoutTransition = { () -> CGRect in
            let center = cell.center
            let size = cell.bounds.size
            let r = CGRect(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height)
            return cell.superview!.convert(r, to: nil)
        }()
        let params = CardTransition.Params(fromCardFrame: cardPresentationFramOnScreen, fromCardWithoutTransform: cardFrameWithoutTransition, fromCell: cell)
        transition = CardTransition(params: params)
        detailVC.transitioningDelegate = transition
        detailVC.modalPresentationStyle = .custom
        present(detailVC, animated: true)
    }
    
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cardHorizonatalOfset: CGFloat = 20
        let cardHeightByWidthRatio: CGFloat = 1.2
        let width = collectionView.bounds.size.width - 2 * cardHorizonatalOfset
        let height: CGFloat = width * cardHeightByWidthRatio
        return CGSize(width: width, height: height)
    }
}



