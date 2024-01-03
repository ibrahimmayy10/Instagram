//
//  EditPostVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 15.10.2023.
//

import UIKit
import Firebase

class EditPostVC: UIViewController {
    
    @IBOutlet weak var explanationTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        explanationTextField.attributedPlaceholder = NSAttributedString(string: "Açıklama yaz...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])

        guard let image = selectedImage else { return }
        imageView.image = image
        
    }
    
    func createUniqueID() -> String {
        let uuid = UUID()
        return uuid.uuidString
    }
    
    @IBAction func shareButton(_ sender: Any) {
        
        let storage = Storage.storage()
        let storeReference = storage.reference()
        
        let mediaFolder = storeReference.child("media")
        
        if let data = selectedImage?.jpegData(compressionQuality: 0.5) {
            
            let uuid = UUID().uuidString
            
            let imageReference = mediaFolder.child("\(uuid).jpg")
            imageReference.putData(data, metadata: nil) { metadata, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else {
                    imageReference.downloadURL { url, error in
                        if error == nil {
                            let imageUrl = url?.absoluteString
                            
                            let firestoreDatabase = Firestore.firestore()
                            
                            let postRef = firestoreDatabase.collection("Posts").document()
                                                        
                            guard let user = Auth.auth().currentUser else { return }
                            let currentUserID = user.uid
                                                        
                            let firestorePost = ["image": imageUrl ?? "", "postedBy": currentUserID, "explanation": self.explanationTextField.text ?? "", "postId": postRef.documentID, "time": FieldValue.serverTimestamp()] as [String: Any]
                            
                            firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { error in
                                if error != nil {
                                    print(error?.localizedDescription ?? "")
                                } else {
                                    let accountVC = self.storyboard?.instantiateViewController(identifier: "toAccountVC") as! AccountVC
                                    self.navigationController?.pushViewController(accountVC, animated: true)
                                    print("post paylaşma başarılı")
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
