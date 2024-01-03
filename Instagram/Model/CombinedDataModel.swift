//
//  CombinedDataModel.swift
//  Instagram
//
//  Created by İbrahim Ay on 12.12.2023.
//

import Foundation

enum MessageType {
    case text
    case video
}

struct CombinedData {
    var message: String?
    var videoUrl: String?
    var senderID: String
    var time: Date
    var messageType: MessageType
}
