//
//  DispatchQueueProtocol.swift
//  
//
//  Created by Horatiu Copaciu on 17.02.2022.
//

import Foundation

public protocol DispatchQueueProtocol {
    func async(group: DispatchGroup?,
               qos: DispatchQoS,
               flags: DispatchWorkItemFlags,
               execute work: @escaping @convention(block) () -> Void)
}

public extension DispatchQueueProtocol {
    func async(execute work: @escaping @convention(block) () -> Void) {
        async(group: nil, qos: .unspecified, flags: [], execute: work)
    }
}

extension DispatchQueue: DispatchQueueProtocol {}
