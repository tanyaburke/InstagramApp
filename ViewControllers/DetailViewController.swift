//
//  DetailViewController.swift
//  InstagramLab
//
//  Created by Tanya Burke on 5/7/20.
//  Copyright © 2020 Tanya Burke. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageDetailLabel: UILabel!
    
  private var item: Item
    private var originalValueForConstraint: CGFloat = 0
    private var databaseService = DatabaseService()
    
    
    init?(coder: NSCoder, item: Item) {
      self.item = item
      super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    private func updateUI() {
      // check if item is a favorite and update heart icon accordingly
//      databaseService.isItemInFavorites(item: item) { [weak self] (result) in
//        switch result {
//        case .failure(let error):
//          DispatchQueue.main.async {
//            self?.showAlert(title: "Try again", message: error.localizedDescription)
//          }
//        case .success(let success):
//          if success { // true
//            self?.isFavorite = true
//          } else {
//            self?.isFavorite = false
//          }
//        }
//      }
//    }
}
    
}
