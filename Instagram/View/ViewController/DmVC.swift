//
//  DmVC.swift
//  Instagram
//
//  Created by İbrahim Ay on 28.10.2023.
//

import UIKit
import Firebase
import SDWebImage

class DmVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var name = String()
    var imageUrl = String()
    var postedBy = String()
    var currentUserID: String?
    
    var message = String()
        
    var allMessages = [MessageModel]()
    var allReels = [SendReelsModel]()
        
    var chatRoomID = String()
    
    var firestoreDatabase = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.automaticallyAdjustsScrollIndicatorInsets = true
        
        currentUserID = Auth.auth().currentUser?.uid
        chatRoomID = generateChatRoomID(user1: currentUserID ?? "", user2: postedBy)
        
        messageTextField.layer.cornerRadius = messageTextField.frame.size.height / 2
        messageTextField.clipsToBounds = true
        
        write()
                
        loadSentMessage()
        loadSentReels()
                        
    }

    
    func write() {
        nameLabel.text = name
        
        imageView.layer.cornerRadius = imageView.layer.frame.width / 2
        imageView.clipsToBounds = true
        
        imageView.sd_setImage(with: URL(string: imageUrl))
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendMessageButton(_ sender: Any) {
        if let message = messageTextField.text, !message.isEmpty {
            sendMessage(message: message)
            messageTextField.text = ""
            
            tableView.reloadData()
            
            DispatchQueue.main.async {
                self.scrollToBottom(animated: true)
            }
        }
    }
    
    func generateChatRoomID(user1: String, user2: String) -> String {
        let sortedIDs = [user1, user2].sorted()
        return sortedIDs.joined(separator: "_")
    }
    
    func sendMessage(message: String) {
        let firestoreMessage = ["message": message, "senderID": currentUserID, "postedBy": postedBy, "chatRoomID": chatRoomID, "time": FieldValue.serverTimestamp()] as [String: Any]
            
        firestoreDatabase.collection("Messages").document(chatRoomID).collection("Message").addDocument(data: firestoreMessage) { error in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                print("başarılı")
                self.loadSentMessage()
            }
        }
    }
    
    func loadSentMessage() {
        firestoreDatabase.collection("Messages").document(chatRoomID).collection("Message").order(by: "time").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Mesaj yüklenemedi: \(error.localizedDescription)")
                return
            }
            
            if let documents = snapshot?.documents {
                var combinedMessages = [MessageModel]()
                
                for document in documents {
                    guard let message = document.get("message") as? String,
                          let senderID = document.get("senderID") as? String,
                          let time = document.get("time") as? Timestamp else {
                        continue
                    }
                    let messageModel = MessageModel(message: message, senderID: senderID, time: time.dateValue(), isIncoming: senderID != currentUserID)
                    combinedMessages.append(messageModel)
                }
                
                combinedMessages.sort { $0.time < $1.time }
                
                allMessages = combinedMessages
                
                tableView.reloadData()
                scrollToBottom(animated: true)
            }
        }
    }
    
    func loadSentReels() {
        firestoreDatabase.collection("Messages").document(chatRoomID).collection("Message").order(by: "time").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Mesaj yüklenemedi: \(error.localizedDescription)")
                return
            }
            
            if let documents = snapshot?.documents {
                var combinedReels = [SendReelsModel]()
                
                for document in documents {
                    guard let videoUrl = document.get("videoUrl") as? String,
                          let senderID = document.get("senderID") as? String,
                          let time = document.get("time") as? Timestamp else {
                        continue
                    }
                    
                    let reelsModel = SendReelsModel(videoUrl: videoUrl, senderID: senderID, time: time.dateValue(), isIncoming: senderID != currentUserID)
                    combinedReels.append(reelsModel)
                }
                
                combinedReels.sort { $0.time < $1.time }
                
                allReels = combinedReels
                
                tableView.reloadData()
                scrollToBottom(animated: true)
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
        return allMessages.count + allReels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        
        if index < allMessages.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageTableViewCell
            let message = allMessages[index]
            cell.configureWithMessage(message.message, isIncoming: message.isIncoming, videoUrl: nil)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageReelsCell", for: indexPath) as! MessageReelsTableViewCell
            let reelsIndex = index - allMessages.count
            let reels = allReels[reelsIndex]
            cell.configureWithReels(reels.videoUrl, isIncoming: reels.isIncoming)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let index = indexPath.row
        
        if index < allMessages.count {
            return 72
        } else {
            return 225
        }
    }
    
}
