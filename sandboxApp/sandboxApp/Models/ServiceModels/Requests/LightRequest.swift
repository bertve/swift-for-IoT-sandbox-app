//
//  LightRequest.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 18/04/2021.
//

import Foundation

class LightRequest: PostRequestModelBasedResourceApiReq<LightRequestModel,MessageResponse> {
    
    init(lightRequestModel: LightRequestModel) {
        super.init(endpoint: "light", requestModel: lightRequestModel)
    }
    
}
