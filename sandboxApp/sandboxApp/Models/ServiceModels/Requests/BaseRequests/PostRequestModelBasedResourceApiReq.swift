//
//  PostRequestModelBasedResourceApiReq.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 18/04/2021.
//

import Foundation

class PostRequestModelBasedResourceApiReq<RequestModel: Codable, ResponseModel: Codable>: RequestModelBasedResourceApiReq<RequestModel,ResponseModel>{
    
    override init(endpoint: String, requestModel: RequestModel) {
        super.init(endpoint: endpoint,requestModel: requestModel)
    }
    
    override var urlReq: URLRequest? {
        var req = super.urlReq
        req?.httpMethod = "POST"
        return req
    }
    
}
