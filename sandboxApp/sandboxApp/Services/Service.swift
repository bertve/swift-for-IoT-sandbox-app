//
//  Service.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 18/04/2021.
//

import Foundation

class Service {

    func sendRequest<Request : ApiRequest>(_ request: Request, completion: @escaping (Result<Request.Response,Error>) -> Void ){
        if let urlRequest = request.urlReq{
            print("sending request...")
            print(urlRequest)
            if let bodyData = urlRequest.httpBody {
                print(bodyData.prettyPrintedJSONString ?? "no body")
            }
            print(urlRequest.allHTTPHeaderFields ?? "no headers")
            Session.defaultSession.dataTask(with: urlRequest){
                (data, response, error) in

                if let data = data {
                    do  {
                        let decodedRes = try request.decodeResponse(data: data)
                        completion(.success(decodedRes))
                    } catch {
                        completion(.failure(error))
                    }
                } else if let error = error {
                    completion(.failure(error))
                }
            }.resume()
        } else {
            completion(.failure(ResponseError.invalidURL))
        }
    }
    
}


extension Data {
    var prettyPrintedJSONString: NSString? {
        /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}
