//
//  BasedResourceApiReq.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 18/04/2021.
//

import Foundation

class BasedResourceApiReq<T: Codable>: ResourceApiReq<T> {
    var baseUrl: String = "https://swift4iot.eu.ngrok.io/gpio/"
    typealias Response = T
    init(endpoint: String) {
        super.init(url: baseUrl + endpoint)
    }
    
}
