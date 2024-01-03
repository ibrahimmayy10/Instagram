//
//  GroupMessageModel.swift
//  Instagram
//
//  Created by İbrahim Ay on 3.11.2023.
//

import Foundation

struct GroupMessageModel {
    var message: String
    var chatRoomID: String
    var senderID: String
    var senderName: String
    var imageUrl: String
    var time: Date
    var isIncoming: Bool
    
    init(message: String, chatRoomID: String, senderID: String, senderName: String, imageUrl: String, time: Date, isIncoming: Bool) {
        self.message = message
        self.chatRoomID = chatRoomID
        self.senderID = senderID
        self.senderName = senderName
        self.imageUrl = imageUrl
        self.time = time
        self.isIncoming = isIncoming
    }
}
