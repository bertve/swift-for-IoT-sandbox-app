//
//  ResourceApiReq.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 18/04/2021.
//

import Foundation

class ResourceApiReq<T : Codable>: ApiRequest {
    typealias Response = T
    
    var url: String
    
    init(url: String) {
        self.url = url
    }
    
    var urlReq: URLRequest? {
        if let safeUrl = URL(string: url){
            return URLRequest(url: safeUrl)
        } else {
            return nil
        }
    }
    
    func decodeResponse(data: Data) throws -> T {
        return try JSONDecoder().decode(T.self, from: data)
    }
    
}
