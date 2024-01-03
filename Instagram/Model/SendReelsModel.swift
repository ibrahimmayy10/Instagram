//
//  SendReelsModel.swift
//  Instagram
//
//  Created by İbrahim Ay on 5.12.2023.
//

import Foundation

struct SendReelsModel {
    var videoUrl: String
    var senderID: String
    var time: Date
    var isIncoming: Bool
    
    init(videoUrl: String, senderID: String, time: Date, isIncoming: Bool) {
        self.videoUrl = videoUrl
        self.senderID = senderID
        self.time = time
        self.isIncoming = isIncoming
    }
}
