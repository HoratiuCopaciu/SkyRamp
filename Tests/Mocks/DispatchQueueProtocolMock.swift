//
//  DispatchQueueProtocolMock.swift
//  
//
//  Created by Horatiu Copaciu on 17.02.2022.
//

import Foundation
import SkyRamp

public class DispatchQueueProtocolMock: DispatchQueueProtocol {
    public init() { }

    public private(set) var asyncCallCount = 0
    public var asyncHandler: ((DispatchGroup?, DispatchQoS, DispatchWorkItemFlags, @escaping @convention(block) () -> Void) -> ())?
    public func async(group: DispatchGroup?, qos: DispatchQoS, flags: DispatchWorkItemFlags, execute work: @escaping @convention(block) () -> Void)  {
        asyncCallCount += 1
        if let asyncHandler = asyncHandler {
            asyncHandler(group, qos, flags, work)
        }
    }
    
    public private(set) var asyncAfterCallCount = 0
    public var asyncAfterHandler: ((DispatchTime, DispatchWorkItem) -> Void)?
    public func asyncAfter(deadline: DispatchTime, execute: DispatchWorkItem) {
        asyncAfterCallCount += 1
        if let asyncAfterHandler = asyncAfterHandler {
            asyncAfterHandler(deadline, execute)
        }
    }
}
