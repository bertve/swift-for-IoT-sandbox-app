//
//  RequestModelBasedResourceApiReq.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 18/04/2021.
//

import Foundation

class RequestModelBasedResourceApiReq<RequestModel: Codable,ResponseModel: Codable>: BasedResourceApiReq<ResponseModel> {
    var requestModel : RequestModel

    init(endpoint: String, requestModel: RequestModel) {
        self.requestModel = requestModel
        super.init(endpoint: endpoint)
    }
    
    override var urlReq: URLRequest?{
        var req = super.urlReq
        req?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req?.httpBody = encodeRequest()
        if let token = Session.formattedSessionToken{
            print("setting token in header")
            req?.setValue(token, forHTTPHeaderField: Session.authHeader )
        }
        return req
    }
    
    private func encodeRequest() -> Data? {
        return try? JSONEncoder().encode(requestModel)
    }
    
}
