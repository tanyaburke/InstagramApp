//
//  FeedCell.swift
//  InstagramLab
//
//  Created by Tanya Burke on 5/7/20.
//  Copyright © 2020 Tanya Burke. All rights reserved.
//

import UIKit
import Kingfisher

class FeedCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var displayName: UILabel!
    
    
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(handleTap(_:)))
        return gesture
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
    }
    
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        
    UINavigationController.showViewController(storyBoardName: "MainView", viewControllerId: "DetailViewController")
        
        print("was tapped")
    }
    
    public func configureCell(for item: Item) {
        
        
        imageView.kf.setImage(with: URL(string: item.imageURL))
        displayName.text = item.sellerName
    }
    
    
    
    
}
