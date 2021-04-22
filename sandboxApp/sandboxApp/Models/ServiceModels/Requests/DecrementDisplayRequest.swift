//
//  DecrementDisplay.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 18/04/2021.
//

import Foundation

class DecrementDisplayRequest: BasedResourceApiReq<String> {
    init() {
        super.init(endpoint: "display/decrement")
    }
}
