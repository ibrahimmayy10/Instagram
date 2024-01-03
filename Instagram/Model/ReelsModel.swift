//
//  ReelsModel.swift
//  Instagram
//
//  Created by İbrahim Ay on 24.10.2023.
//

import Foundation

struct ReelsModel {
    let videoUrl: String
    let explanation: String
    let postedBy: String
    let reelsId: String
    
    static func createFrom (_ data: [String: Any]) -> ReelsModel {
        guard let videoUrl = data["videoUrl"] as? String, let explanation = data["explanation"] as? String, let postedBy = data["postedBy"] as? String, let reelsId = data["reelsId"] as? String else {
            return ReelsModel(videoUrl: "", explanation: "", postedBy: "", reelsId: "")
        }
        return ReelsModel(videoUrl: videoUrl, explanation: explanation, postedBy: postedBy, reelsId: reelsId)
    }
}
