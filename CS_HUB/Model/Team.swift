//
//  TeamDocument.swift
//  CS_HUB
//
//  Created by Nikstanov on 14.03.24.
//

import Foundation

struct Team : Hashable, Codable, Identifiable{
    let id: Int
    let team_name: String
    let year_created_at: Int
}
