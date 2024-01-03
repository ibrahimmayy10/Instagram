//
//  StoryModel.swift
//  Instagram
//
//  Created by İbrahim Ay on 16.12.2023.
//

import Foundation
import Firebase

struct StoryModel {
    let imageUrl: String
    let postedBy: String
    let storyID: String
    let timestamp: Timestamp?
    
    static func createFrom (_ data: [String: Any]) -> StoryModel {
        let imageUrl = data["imageUrl"] as? String
        let postedBy = data["postedBy"] as? String
        let storyID = data["storyID"] as? String
        let timestamp = data["time"] as? Timestamp
        
        return StoryModel(imageUrl: imageUrl ?? "", postedBy: postedBy ?? "", storyID: storyID ?? "", timestamp: timestamp)
    }
}
