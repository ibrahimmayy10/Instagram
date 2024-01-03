//
//  CreateGroupVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 3.11.2023.
//

import UIKit
import Firebase

class CreateGroupVC: UIViewController {

    @IBOutlet weak var groupNameTextField: UITextField!
    
    var chatRoomID = String()
    var userList = [String]()
    var nameList = [String]()
    
    var currentUserID: String?
    var firestoreDatabase = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupNameTextField.attributedPlaceholder = NSAttributedString(string: "Grup ismini yaz...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        
        currentUserID = Auth.auth().currentUser?.uid
        chatRoomID = UUID().uuidString
        
        userList.append(currentUserID ?? "")
        
    }

    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createButton(_ sender: Any) {
        let groupName = groupNameTextField.text
        let firestoreGroup = ["name": nameList, "groupName": groupName, "chatRoomID": chatRoomID, "users": userList] as [String: Any]
        
        firestoreDatabase.collection("MessageRoom").addDocument(data: firestoreGroup) { error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                print("grup kuruldu")
                let personVC = self.storyboard?.instantiateViewController(identifier: "toDmPersonVC") as! DMPersonsVC
                self.navigationController?.pushViewController(personVC, animated: true)
            }
        }
    }
    
}
