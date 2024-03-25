//
//  Review.swift
//  CS_HUB
//
//  Created by Elena on 25.03.24.
//

import Foundation

struct Review : Hashable, Codable, Identifiable{
    let id:Int
    let userId: String
    let text: String
    let name: String
}
