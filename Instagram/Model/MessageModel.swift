//
//  MessageModel.swift
//  Instagram
//
//  Created by İbrahim Ay on 30.10.2023.
//

import Foundation

struct MessageModel {
    var message: String
    var senderID: String
    var time: Date
    var isIncoming: Bool
    var videoUrl: String?
    
    init(message: String, senderID: String, time: Date, isIncoming: Bool, videoUrl: String? = nil) {
        self.message = message
        self.senderID = senderID
        self.time = time
        self.isIncoming = isIncoming
        self.videoUrl = videoUrl
    }
}
