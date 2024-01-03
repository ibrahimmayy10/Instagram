//
//  RegisterVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 14.10.2023.
//

import UIKit
import Firebase

class RegisterVC: UIViewController, UIImagePickerControllerDelegate,  UINavigationControllerDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var biograpghyTextField: UITextField!
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        
    }
    
    @IBAction func selectProfileImageButton(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        imageView.image = selectedImage
        dismiss(animated: true)
    }
    
    @IBAction func registerButton(_ sender: Any) {
        let email = emailTextField.text
        let username = usernameTextField.text
        let name = nameTextField.text
        let password = passwordTextField.text
        let biography = biograpghyTextField.text
        
        guard ((email?.isEmpty) != nil) && ((username?.isEmpty) != nil) && ((name?.isEmpty) != nil) && ((password?.isEmpty) != nil) && ((biography?.isEmpty) != nil) else {
            let alert = UIAlertController(title: "", message: "Tüm alanları doldurmak zorunludur", preferredStyle: .alert)
            let okButton = alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
            return
        }
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let mediaFolder = storageReference.child("userProfileImage")
        
        if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
            
            let uuid = UUID().uuidString
            
            let imageReference = mediaFolder.child("\(uuid).jpg")
            
            imageReference.putData(data, metadata: nil) { metadata, error in
                if error != nil {
                    self.makeAlert(messageInput: error?.localizedDescription ?? "")
                } else {
                    imageReference.downloadURL { url, error in
                        if error == nil {
                            if email != nil || name != nil || password != nil {
                                Auth.auth().createUser(withEmail: email ?? "", password: password ?? "") { authresult, error in
                                    if error != nil {
                                        self.makeAlert(messageInput: error?.localizedDescription ?? "")
                                    } else {
                                        let imageUrl = url?.absoluteString
                                        
                                        let firestoreDatabase = Firestore.firestore()
                                        
                                        var firestoreReference : DocumentReference? = nil
                                        
                                        guard let user = Auth.auth().currentUser else { return }
                                        let currentUserID = user.uid
                                        let users = ["name": name, "username": username, "imageUrl": imageUrl ?? "", "postedBy": currentUserID, "biography": biography]

                                        firestoreReference = firestoreDatabase.collection("users").document(authresult?.user.uid ?? "")
                                        
                                        firestoreReference?.setData(users, merge: true) { error in
                                            if error != nil {
                                                self.makeAlert(messageInput: error?.localizedDescription ?? "")
                                            } else {
                                                let vc = self.storyboard?.instantiateViewController(identifier: "toVC") as! ViewController
                                                self.navigationController?.pushViewController(vc, animated: true)
                                            }
                                        }
                                    }
                                }
                            } else {
                                self.makeAlert(messageInput: "Lütfen tüm alanları doldurunuz")
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    func makeAlert (messageInput: String) {
        let alert = UIAlertController(title: "", message: messageInput, preferredStyle: .alert)
        let okButton = alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    @IBAction func signinButton(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "toVC") as! ViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
