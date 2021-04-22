//
//  RPIService.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 18/04/2021.
//

import Foundation

class RPIService: Service {
        
    // light
    func toggleLight(requestModel: LightRequestModel,completion: @escaping (Result<MessageResponse,Error>) -> Void) {
        super.sendRequest(LightRequest(lightRequestModel: requestModel), completion: completion)
    }
    
    // display
    func incrementDisplay(completion: @escaping (Result<String,Error>) -> Void) {
        super.sendRequest(IncrementDisplayRequest(), completion: completion)
    }
    
    func decrementDisplay(completion: @escaping (Result<String,Error>) -> Void) {
        super.sendRequest(DecrementDisplayRequest(), completion: completion)
    }
    
    func displayNumber(requestModel: DisplayNumberRequestModel,completion: @escaping (Result<MessageResponse,Error>) -> Void) {
        super.sendRequest(DisplayNumberRequest(displayNumberRequestModel: requestModel), completion: completion)
    }
    
    // temperature
    func fetchTemperature(completion: @escaping (Result<MessageResponse,Error>) -> Void) {
        super.sendRequest(TemperatureRequest(), completion: completion)
    }
    
}
