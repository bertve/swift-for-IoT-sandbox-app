//
//  DisplayNumberRequest.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 18/04/2021.
//

import Foundation

class DisplayNumberRequest: PostRequestModelBasedResourceApiReq<DisplayNumberRequestModel,MessageResponse> {
    
    init(displayNumberRequestModel: DisplayNumberRequestModel) {
        super.init(endpoint: "display", requestModel: displayNumberRequestModel)
    }
    
}
