//
//  UpLoadImageViewController.swift
//  InstagramLab
//
//  Created by Tanya Burke on 5/7/20.
//  Copyright © 2020 Tanya Burke. All rights reserved.
//

import UIKit
import FirebaseAuth // authentication
import FirebaseFirestore // database (firestore)

class UpLoadImageViewController: UIViewController {
    
    @IBOutlet weak var imageview: UIImageView!
    private var imagePickerController = UIImagePickerController()
    private let dbService = DatabaseService()
    private let storageService = StorageService()
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(handleTap(_:)))
        return gesture
    }()
    
    private var selectedImage: UIImage? {
        didSet {
            imageview.image = selectedImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageview.isUserInteractionEnabled = true
        imageview.addGestureRecognizer(tapGesture)
        imagePickerController.delegate = self
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        
        chooseImage()
        
        print("was tapped")
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
    
    private func showImageController(isCameraSelected: Bool) {
        // source type default will be .photoLibrary
        imagePickerController.sourceType = .photoLibrary
        
        if isCameraSelected {
            imagePickerController.sourceType = .camera
        }
        present(imagePickerController, animated: true)
    }
    
    
    @IBAction func uploadButtonPressed(_ sender: UIButton) {
        
        sender.isEnabled = false
        
        guard let selectedImage = selectedImage else {
            showAlert(title: "Missing Fields", message: "All fields are required along with a photo.")
            sender.isEnabled = true
            return

        }
        guard let displayName = Auth.auth().currentUser?.displayName else {
            showAlert(title: "Incomplete Profile", message: "Please complete your Profile.")
            sender.isEnabled = true
            return
        }
        
        let resizedImage = UIImage.resizeImage(originalImage: selectedImage, rect: imageview.bounds)
        
        dbService.createItem(displayName: displayName) { [weak self, weak sender] (result) in
            switch result {
            case.failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error creating item", message: "Sorry something went wrong: \(error.localizedDescription)")
                    sender?.isEnabled = true
                }
            case .success(let documentId):
                self?.uploadPhoto(photo: resizedImage, documentId: documentId)
                sender?.isEnabled = true
            }
        }
    }
    
    private func uploadPhoto(photo: UIImage, documentId: String) {
        storageService.uploadPhoto(itemId: documentId, image: photo) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error uploading photo", message: "\(error.localizedDescription)")
                }
            case .success(let url):
                self?.updateItemImageURL(url, documentId: documentId)
            }
        }
    }
    
    private func updateItemImageURL(_ url: URL, documentId: String) {
        // update an existing document on Firebase
        Firestore.firestore().collection(DatabaseService.itemsCollection).document(documentId).updateData(["imageURL" : url.absoluteString]) { [weak self] (error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Fail to update item", message: "\(error.localizedDescription)")
                }
            } else {
                // everything went ok
                print("all went well with the update")
                DispatchQueue.main.async {
                    self?.dismiss(animated: true)
                }
            }
        }
    }
    
    
}








extension UpLoadImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        
        imageview.image = image
        
        
        dismiss(animated: true)
    }
}
