//
//  ApiRequest.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 18/04/2021.
//

import Foundation

protocol ApiRequest {
    associatedtype Response
    
    var url : String { get }
    var urlReq : URLRequest? { get }
    func decodeResponse(data: Data) throws -> Response
}
