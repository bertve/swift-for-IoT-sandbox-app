//
//  DoorRequest.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 11/05/2021.
//

import Foundation

struct DoorRequestModel: Codable {
    let openDoor : Bool

    enum CodingKeys: String, CodingKey {
        case openDoor
    }
}
