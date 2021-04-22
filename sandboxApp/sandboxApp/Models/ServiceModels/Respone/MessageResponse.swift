//
//  MessageResonse.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 19/04/2021.
//

import Foundation

struct MessageResponse: Codable {
    var message: String
    
    enum CodingKeys: String, CodingKey {
        case message
    }
}
