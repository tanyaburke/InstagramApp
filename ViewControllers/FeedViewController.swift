//
//  FeedViewController.swift
//  InstagramLab
//
//  Created by Tanya Burke on 5/7/20.
//  Copyright © 2020 Tanya Burke. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FeedViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
   private var listener: ListenerRegistration?
   
    private var imageObjects = [Item]() {
      didSet {
        DispatchQueue.main.async {
          self.collectionView.reloadData()
        }
      }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
    }
    
     override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        listener = Firestore.firestore().collection(DatabaseService.itemsCollection).addSnapshotListener({ [weak self] (snapshot, error) in
          if let error = error {
            DispatchQueue.main.async {
              self?.showAlert(title: "Try again later", message: "\(error.localizedDescription)")
            }
          } else if let snapshot = snapshot {
            let items = snapshot.documents.map { Item($0.data()) }
            self?.imageObjects = items
          }
        })
      }
    
      
      override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        listener?.remove() // no longer are we listening for changes from Firebase
      }
    
    
    }


extension FeedViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxWidth: CGFloat = UIScreen.main.bounds.size.width
        let itemWidth: CGFloat = maxWidth * 0.80
        return CGSize(width: itemWidth, height: itemWidth)  }
    
}

extension FeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//    return imageObjects.count
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "feedCell", for: indexPath) as? FeedCell else {
            fatalError("Was expecting an CollectionViewCell, but found a different type")
        }
//        let image = images[indexPath.row]
//          let imageObject = imageObjects[indexPath.row]
//        cell.configureCell(imageObject: imageObject)
        
//        cell.delegate = self
        return cell
    }
}
