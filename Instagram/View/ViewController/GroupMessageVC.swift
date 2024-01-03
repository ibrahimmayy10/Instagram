//
//  GroupMessageVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 3.11.2023.
//

import UIKit
import Firebase

class GroupMessageVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var groupNameLabel: UILabel!
    
    var groupName = String()
    var chatRoomID = String()
    var name = String()
    var imageUrl = String()
    
    var allMessages = [GroupMessageModel]()
    
    var currentUserID: String?
    var firestore = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        currentUserID = Auth.auth().currentUser?.uid
        
        messageTextField.layer.cornerRadius = messageTextField.frame.size.height / 2
        messageTextField.clipsToBounds = true
        messageTextField.attributedPlaceholder = NSAttributedString(string: "Mesaj yaz...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        
        groupNameLabel.text = groupName
        
        getDataName()
        loadMessage()
        
    }
    
    func getDataName() {
        firestore.collection("users").whereField("postedBy", isEqualTo: currentUserID).addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else if let documents = snapshot?.documents {
                for document in documents {
                    guard let username = document.get("username") as? String, let imageUrl = document.get("imageUrl") as? String else { return }
                    self.name = username
                    self.imageUrl = imageUrl
                }
            }
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendMessageButton(_ sender: Any) {
        if let message = messageTextField.text, !message.isEmpty {
            sendMessage(message: message)
            messageTextField.text = ""
        }
    }
    
    func sendMessage(message: String) {
        var firestoreMessage = ["message": message, "chatRoomID": chatRoomID, "postedBy": currentUserID, "senderName": name, "imageUrl": imageUrl, "time": FieldValue.serverTimestamp()] as [String: Any]
        
        firestore.collection("GroupMessages").document(chatRoomID).collection("GroupMessage").addDocument(data: firestoreMessage) { error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                print("grup mesajı gönderildi")
                self.loadMessage()
            }
        }
    }
    
    func loadMessage() {
        firestore.collection("GroupMessages").document(chatRoomID).collection("GroupMessage").order(by: "time").addSnapshotListener { [weak self] snapshot, error in
            
            guard let self = self else { return }
            if let error = error {
                print("Mesaj yüklenemedi: \(error.localizedDescription)")
                return
            }
            
            if let documents = snapshot?.documents {
                var combinedMessages = [GroupMessageModel]()
                
                for document in documents {
                    guard let message = document.get("message") as? String,
                          let chatRoomID = document.get("chatRoomID") as? String,
                          let senderID = document.get("postedBy") as? String,
                          let senderName = document.get("senderName") as? String,
                          let imageUrl = document.get("imageUrl") as? String,
                          let time = document.get("time") as? Timestamp else {
                        continue
                    }
                    
                    let groupMessageModel = GroupMessageModel(message: message, chatRoomID: chatRoomID, senderID: senderID, senderName: senderName, imageUrl: imageUrl, time: time.dateValue(), isIncoming: senderID != currentUserID)
                    
                    combinedMessages.append(groupMessageModel)
                    
                    combinedMessages.sort { $0.time < $1.time }
                    
                    allMessages = combinedMessages
                    tableView.reloadData()
                    scrollToBottom(animated: true)
                }
            }
        }
    }
    
    func scrollToBottom(animated: Bool) {
        DispatchQueue.main.async {
            let lastSection = self.tableView.numberOfSections - 1
            guard lastSection >= 0 else {
                return
            }
            
            let lastRow = self.tableView.numberOfRows(inSection: lastSection) - 1
            guard lastRow >= 0 else {
                return
            }
            
            let indexPath = IndexPath(row: lastRow, section: lastSection)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupMessageCell", for: indexPath) as! GroupMessageTableViewCell
        let message = allMessages[indexPath.row]
        
        cell.configureWithMessage(message.message, username: message.senderName, imageUrl: message.imageUrl, isIncoming: message.isIncoming)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
}
