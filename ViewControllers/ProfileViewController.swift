//
//  ProfileViewController.swift
//  InstagramLab
//
//  Created by Tanya Burke on 5/7/20.
//  Copyright © 2020 Tanya Burke. All rights reserved.
//

import UIKit
import FirebaseAuth // authentication
import FirebaseFirestore // database (firestore)
import Kingfisher


class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: DesignableImageView!
    @IBOutlet weak var displayNameLabel: DesignableTextField!
    @IBOutlet weak var profileDetailsLabel: UILabel!
    @IBOutlet weak var profileLabel: UILabel!
    
     private var listener: ListenerRegistration?
    private let dbService = DatabaseService()
      private let storageService = StorageService()
    
    private lazy var imagePickerController: UIImagePickerController = {
      let ip = UIImagePickerController()
      ip.delegate = self
      return ip
    }()
    
    private var selectedImage: UIImage? {
      didSet {
        profileImage.image = selectedImage
      }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayNameLabel.delegate = self
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        listener = Firestore.firestore().collection(DatabaseService.usersCollection).document("displayName").addSnapshotListener({ [weak self] (snapshot, error) in
          if let error = error {
            DispatchQueue.main.async {
              self?.showAlert(title: "Try again later", message: "\(error.localizedDescription)")
            }
          } else if let snapshot = snapshot {
            let userinfo = snapshot.data() // Item($0.data()) }
//            self?.profileLabel.text = userinfo?.first.debugDescription
                
          }
        })
      }
      
      override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        listener?.remove() // no longer are we listening for changes from Firebase
      }
    
    
    
    
    private func updateUI() {
      guard let user = Auth.auth().currentUser else {
        return
      }
      profileDetailsLabel.text = user.email
//      profileLabel.text = user.displayName
      displayNameLabel.text = user.displayName
      profileImage.kf.setImage(with: user.photoURL)
     
    }
    
    
    
    
       
       private func showImageController(isCameraSelected: Bool) {
           // source type default will be .photoLibrary
           imagePickerController.sourceType = .photoLibrary
           
           if isCameraSelected {
               imagePickerController.sourceType = .camera
           }
           present(imagePickerController, animated: true)
       }
       
    
    
    
    
    @IBAction func signOutPressed(_ sender: UIButton) {
        
        do {
            try Auth.auth().signOut()
            UIViewController.showViewController(storyBoardName: "Login", viewControllerId: "LoginViewController")
          } catch {
            DispatchQueue.main.async {
              self.showAlert(title: "Error signing out", message: "\(error.localizedDescription)")
            }
          }
        }
        
    
    private func chooseImage(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] alertAction in
            self?.showImageController(isCameraSelected: true)
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { [weak self] alertAction in
            self?.showImageController(isCameraSelected: false)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // check if camera is available, if camera is not available and you attempt to show
        // the camera the app will crash
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(cameraAction)
        }
        
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
        
    }

    
    @IBAction func changeProfilePicture(_ sender: UIButton) {
        chooseImage()
        
        
        
    }
    
    
    
    
    private func updateDatabaseUser(displayName: String, photoURL: String) {
      dbService.updateDatabaseUser(displayName: displayName, photoURL: photoURL) { (result) in
        switch result {
        case .failure(let error):
          print("failed to update db user: \(error.localizedDescription)")
        case .success:
          print("successfully updated db user")
        }
      }
    }
    
    
    
    @IBAction func updateProfilePressed(_ sender: UIButton) {
        
        guard let displayName = displayNameLabel.text,
            !displayName.isEmpty,
            let selectedImage = selectedImage else {
    DispatchQueue.main.async {
        self.showAlert(title: "Profile Error", message: "missing fields")
        
    }
                return
        }
          
          guard let user = Auth.auth().currentUser else { return }
          
          // resize image before uploading to Firebase
          let resizedImage = UIImage.resizeImage(originalImage: selectedImage, rect: profileImage.bounds)
          
          print("original image size: \(selectedImage.size)")
          print("resized image size: \(resizedImage)")
          
          // call storageService.upload
          storageService.uploadPhoto(userId: user.uid, image: resizedImage) { [weak self] (result) in
            // code here to add the photoURL to the user's photoURL property then commit changes
            switch result {
            case .failure(let error):
              DispatchQueue.main.async {
                self?.showAlert(title: "Error uploading photo", message: "\(error.localizedDescription)")
              }
            case .success(let url):
              
              self?.updateDatabaseUser(displayName: displayName, photoURL: url.absoluteString)
              
              // TODO: refactor into its own function
              let request = Auth.auth().currentUser?.createProfileChangeRequest()
              request?.displayName = displayName
              request?.photoURL = url
              request?.commitChanges(completion: { [unowned self] (error) in
                if let error = error {
                  DispatchQueue.main.async {
                    self?.showAlert(title: "Error updating profile", message: "Error changing profile: \(error.localizedDescription).")
                  }
                } else {
                  DispatchQueue.main.async {
                    self?.showAlert(title: "Profile Update", message: "Profile successfully updated 🥳.")
                  }
                }
              })
            }
          }
        }
        
    
    
 

}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // we need to access the UIImagePickerController.InfoKey.orginalImage key to get the
        // UIImage that was selected
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("image selected not found")
            return
        }
        
        profileImage.image = image
        
        
        dismiss(animated: true)
    }
}


extension ProfileViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}


