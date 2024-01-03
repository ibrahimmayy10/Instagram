//
//  EditVideoVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 21.10.2023.
//

import UIKit
import Firebase

class EditVideoVC: UIViewController {
    
    @IBOutlet weak var explanationTextField: UITextField!
    var videoUrl: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        explanationTextField.attributedPlaceholder = NSAttributedString(string: "Açıklama yaz...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        
    }
    
    @IBAction func shareButton(_ sender: Any) {
        let explanation = explanationTextField.text
        let firebaseDatabase = Firestore.firestore()
        
        guard let user = Auth.auth().currentUser else { return }
        let currentUserID = user.uid
        
        let reelsRef = firebaseDatabase.collection("Reels").document()
        
        let firestoreReels = ["videoUrl": videoUrl?.absoluteString ?? "", "explanation": explanation ?? "", "postedBy": currentUserID, "reelsId": reelsRef.documentID] as [String : Any]
        
        firebaseDatabase.collection("Reels").addDocument(data: firestoreReels) { error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                let reelsVC = self.storyboard?.instantiateViewController(identifier: "toReelsVC") as! ReelsVC
                self.navigationController?.pushViewController(reelsVC, animated: true)
            }
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
