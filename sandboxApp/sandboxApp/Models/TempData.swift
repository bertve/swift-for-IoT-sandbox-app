//
//  TempData.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 29/04/2021.
//

import Foundation

struct TempData: Codable {

    let dateTime = Date()
    let ambientTemp: Double
    let objectTemp: Double

    enum CodingKeys: String, CodingKey {
        case dateTime
        case ambientTemp
        case objectTemp
    }
    
}
