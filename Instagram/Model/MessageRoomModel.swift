//
//  MessageRoomModel.swift
//  Instagram
//
//  Created by İbrahim Ay on 3.11.2023.
//

import Foundation

struct MessageRoomModel {
    var chatRoomID: String
    var users: [String]
    var groupName: String
    
    init(chatRoomID: String, users: [String], groupName: String) {
        self.chatRoomID = chatRoomID
        self.users = users
        self.groupName = groupName
    }
}
