//
//  PostsModel.swift
//  Instagram
//
//  Created by İbrahim Ay on 14.10.2023.
//

import Foundation
import FirebaseFirestore

struct PostModel {
    let imageUrl: String
    let explanation: String
    let postedBy: String
    let postId: String
    
    static func createFrom (_ data: [String: Any]) -> PostModel {
        let imageUrl = data["image"] as? String
        let explanation = data["explanation"] as? String
        let postedBy = data["postedBy"] as? String
        let postId = data["postId"] as? String
        return PostModel(imageUrl: imageUrl ?? "", explanation: explanation ?? "", postedBy: postedBy ?? "", postId: postId ?? "")
    }
}
