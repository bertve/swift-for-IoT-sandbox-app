//
//  TemperatureRequest.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 18/04/2021.
//

import Foundation

class TemperatureRequest: BasedResourceApiReq<MessageResponse> {
    init() {
        super.init(endpoint: "temperature")
    }
}
