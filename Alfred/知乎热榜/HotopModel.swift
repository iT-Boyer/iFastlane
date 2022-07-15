//
//  HotopModel.swift
//  Alfred
//
//  Created by boyer on 2022/7/15.
//

import Foundation
// MARK: - Welcome
struct HotopModel: Codable {
    let data: [HotDatum]?
    let freshText: String?
    let displayNum: Int?

    enum CodingKeys: String, CodingKey {
        case data
        case freshText = "fresh_text"
        case displayNum = "display_num"
    }
    
    // 解析
    static func parsed<T:Decodable>(data:Data?) -> T?{
        
        guard let origin = data else { return nil }
        do{
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: origin)
        }catch{
            return nil
        }
    }
}

// MARK: - Datum
struct HotDatum: Codable {
    let styleType, id, cardID: String?
    let target: HotTarget?
    let attachedInfo, detailText: String?
    let trend: Int?
    let debut: Bool?
    let children: [Child]?

    enum CodingKeys: String, CodingKey {
        case styleType = "style_type"
        case id
        case cardID = "card_id"
        case target
        case attachedInfo = "attached_info"
        case detailText = "detail_text"
        case trend, debut, children
    }
}

// MARK: - Child
struct Child: Codable {
    let type: ChildType?
    let thumbnail: String?
}

enum ChildType: String, Codable {
    case answer = "answer"
}

// MARK: - Target
struct HotTarget: Codable {
    let id: Int?
    let title: String?
    let url: String?
    let created, answerCount, followerCount: Int?
    let author: Author?
    let boundTopicIDS: [Int]?
    let commentCount: Int?
    let isFollowing: Bool?
    let excerpt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, url, created
        case answerCount = "answer_count"
        case followerCount = "follower_count"
        case author
        case boundTopicIDS = "bound_topic_ids"
        case commentCount = "comment_count"
        case isFollowing = "is_following"
        case excerpt
    }
}

// MARK: - Author
struct Author: Codable {
    let id, urlToken, url: String?
    let headline: String?
    let avatarURL: String?

    enum CodingKeys: String, CodingKey {
        case id
        case urlToken = "url_token"
        case url, headline
        case avatarURL = "avatar_url"
    }
}
