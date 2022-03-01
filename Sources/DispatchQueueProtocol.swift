//
//  DispatchQueueProtocol.swift
//  
//
//  Created by Horatiu Copaciu on 17.02.2022.
//

import Foundation
import Combine

public protocol DispatchQueueProtocol {
    func async(group: DispatchGroup?,
               qos: DispatchQoS,
               flags: DispatchWorkItemFlags,
               execute work: @escaping @convention(block) () -> Void)
    func asyncAfter(deadline: DispatchTime, execute: DispatchWorkItem)
    
    func receive<Output, Failure: Error>(publisher: AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure>
}

public extension DispatchQueueProtocol {
    func async(execute work: @escaping @convention(block) () -> Void) {
        async(group: nil, qos: .unspecified, flags: [], execute: work)
    }
}

extension DispatchQueue: DispatchQueueProtocol {
    public func receive<Output, Failure: Error>(publisher: AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        publisher
            .receive(on: self, options: nil)
            .eraseToAnyPublisher()
    }
}

extension AnyPublisher {
    func receive(on dispatchQueue: DispatchQueueProtocol) -> Self {
        dispatchQueue.receive(publisher: self)
    }
}
