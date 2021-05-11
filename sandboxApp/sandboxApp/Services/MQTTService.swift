//
//  MQTT.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 26/04/2021.
//

import Foundation
import NIO
import MQTTNIO
import NIOSSL

class MQTTService {

    var client: MQTTClient
    var jsonEncoder = JSONEncoder()

    init(host: String = "ac24c670632142bab0a422606038f608.s1.eu.hivemq.cloud", port: Int = 8883) {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 2)
        var config = MQTTConfiguration(target: .host( host, port: port))
        config.credentials = MQTTConfiguration.Credentials(username: "bertve",password: "Swift4iot")
        config.tls = TLSConfiguration.clientDefault
        self.client = MQTTClient(
            configuration: config,
            eventLoopGroup: group
        )
        client.connect()
    }

    func subscribe(to topicString: String) {
        client.subscribe(to: topicString).whenComplete { result in
            switch result {
            case .success(.success):
                print("Subscribed!")
            case .success(.failure):
                print("Server rejected")
            case .failure:
                print("Server did not respond")
            }
        }
    }

    func unsubscribe(from topicString: String) {
        client.unsubscribe(from: topicString).whenComplete { result in
            switch result {
            case .success:
                print("Unsubscribed!")
            case .failure:
                print("Server did not respond")
            }
        }
    }
    
    func publish<T: Codable>(to topic: String, with payload: T) {
        
        if let jsonPayload = try? jsonEncoder.encode(payload),
            let jsonString = jsonPayload.prettyPrintedJSONString {
            client.publish(topic: topic, payload: jsonString as String)
        }
    }

}
