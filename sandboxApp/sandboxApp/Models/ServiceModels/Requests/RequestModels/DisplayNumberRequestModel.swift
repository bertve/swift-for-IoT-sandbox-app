//
//  DisplayNumberRequestModel.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 18/04/2021.
//

import Foundation

struct DisplayNumberRequestModel: Codable {
    let number: Int
    
    enum Codingkeys: String, CodingKey {
        case number
    }
    
}
