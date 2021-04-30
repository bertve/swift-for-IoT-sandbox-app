//
//  MQTT.swift
//  sandboxApp
//
//  Created by Bert Van eeckhoutte on 26/04/2021.
//

import Foundation
import NIO
import MQTTNIO

class MQTTService {

    var client: MQTTClient
    let remote_host = "https://github.com/sroebert/mqtt-nio.git"

    init(host: String = "192.168.0.125", port: Int = 1883) {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 2)
        self.client = MQTTClient(
            configuration: .init(
                target: .host( host, port: port)
            ),
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

}
