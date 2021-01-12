//
//  BackgroundTask.swift
//
//  Created by Horatiu Copaciu on 05/07/2019.
//  Copyright © 2019 Horatiu Copaciu. All rights reserved.
//

import Foundation

@objc protocol BackgroundTask: class {
    var identifier: Int { get }
    
    static func executeTask() -> BackgroundTask
    func end()
}

extension BackgroundTask {
    static func executeTask(completion: @escaping (BackgroundTask) -> Void) {
        completion(executeTask())
    }
}
