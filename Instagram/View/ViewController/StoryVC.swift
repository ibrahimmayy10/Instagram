//
//  StoryVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 14.12.2023.
//

import UIKit
import Firebase

class StoryVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    
    var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        backBtn.layer.cornerRadius = backBtn.frame.size.width / 2
        backBtn.clipsToBounds = true
        
        imageView.image = selectedImage
                
    }

    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareButton(_ sender: Any) {
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let storyFolder = storageReference.child("story")
        
        if let data = selectedImage?.jpegData(compressionQuality: 0.5) {
            let uuid = UUID().uuidString
            
            let imageReference = storyFolder.child("\(uuid).jpg")
            
            imageReference.putData(data, metadata: nil) { metadata, error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else {
                    imageReference.downloadURL { url, error in
                        if error == nil {
                            let imageUrl = url?.absoluteString
                            
                            let firestore = Firestore.firestore()
                            
                            let storyRef = firestore.collection("Story").document()
                            
                            guard let user = Auth.auth().currentUser else { return }
                            let currentUserID = user.uid
                            
                            let firestoreStory = ["imageUrl": imageUrl, "postedBy": currentUserID, "storyID": storyRef.documentID, "time": FieldValue.serverTimestamp()] as [String: Any]
                            
                            firestore.collection("Story").addDocument(data: firestoreStory) { error in
                                if error != nil {
                                    print(error?.localizedDescription ?? "")
                                } else {
                                    print("story başarıyla paylaşıldı")
                                    let homeVC = self.storyboard?.instantiateViewController(identifier: "toHomePageVC") as! HomePageVC
                                    self.navigationController?.pushViewController(homeVC, animated: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
}
