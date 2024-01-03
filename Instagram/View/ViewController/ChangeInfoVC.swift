//
//  ChangeInfoVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 19.12.2023.
//

import UIKit
import Firebase

class ChangeInfoVC: UIViewController {

    @IBOutlet weak var resultsTextField: UITextField!
    @IBOutlet weak var sectionsLabel: UILabel!
    
    var section = String()
    var result = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        sectionsLabel.text = section
        resultsTextField.text = result
        
    }

    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let newResult = resultsTextField.text
        
        guard let user = Auth.auth().currentUser else { return }
        let currentUserID = user.uid
        
        let firestore = Firestore.firestore()
        
        if section == "Adı" {
            let newData = ["name": newResult]
            firestore.collection("users").document(currentUserID).updateData(newData) { error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else {
                    print("değiştirme işlemi başarılı")
                    let accountVC = self.storyboard?.instantiateViewController(identifier: "toAccountVC") as! AccountVC
                    self.navigationController?.pushViewController(accountVC, animated: true)
                }
            }
        } else if section == "Kullanıcı adı" {
            let newData = ["username": newResult]
            firestore.collection("users").document(currentUserID).updateData(newData) { error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else {
                    print("değiştirme işlemi başarılı")
                    let accountVC = self.storyboard?.instantiateViewController(identifier: "toAccountVC") as! AccountVC
                    self.navigationController?.pushViewController(accountVC, animated: true)
                }
            }
        } else if section == "Biyografi" {
            let newData = ["biography": newResult]
            firestore.collection("users").document(currentUserID).updateData(newData) { error in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                } else {
                    print("değiştirme işlemi başarılı")
                    let accountVC = self.storyboard?.instantiateViewController(identifier: "toAccountVC") as! AccountVC
                    self.navigationController?.pushViewController(accountVC, animated: true)
                }
            }
        }
    }
    
}
