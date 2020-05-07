//
//  UpLoadImageViewController.swift
//  InstagramLab
//
//  Created by Tanya Burke on 5/7/20.
//  Copyright © 2020 Tanya Burke. All rights reserved.
//

import UIKit

class UpLoadImageViewController: UIViewController {

    @IBOutlet weak var imageview: UIImageView!
    private var imagePickerController = UIImagePickerController()
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(handleTap(_:)))
        return gesture
    }()
    
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
        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
