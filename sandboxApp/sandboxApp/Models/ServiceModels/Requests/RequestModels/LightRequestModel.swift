//
//  LightRequestModel.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 18/04/2021.
//

import Foundation

struct LightRequestModel: Codable {
    let toggleOn: Bool
    
    enum CodingKeys: String, CodingKey {
        case toggleOn
    }
    
}
