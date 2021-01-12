//
//  ApplicationBackgroundTask.swift
//
//  Created by Horatiu Copaciu on 05/07/2019.
//  Copyright © 2019 Horatiu Copaciu. All rights reserved.
//

import UIKit

@objcMembers
final class ApplicationBackgroundTask: NSObject, BackgroundTask {
    
    let application: UIApplication
    private(set) var identifier: Int
    private var taskIdentifier: UIBackgroundTaskIdentifier
    
    private init(application: UIApplication) {
        self.application = application
        self.taskIdentifier = .invalid
        self.identifier = self.taskIdentifier.rawValue
    }
    
    class func executeTask() -> BackgroundTask {
        let task = ApplicationBackgroundTask(application: .shared)
        task.execute()
        return task
    }
    
    private func execute() {
        taskIdentifier = application.beginBackgroundTask(expirationHandler: { [weak self] in
            self?.end()
        })
        identifier = taskIdentifier.rawValue
    }
    
    func end() {
        guard taskIdentifier != .invalid else { return }
        application.endBackgroundTask(taskIdentifier)
        taskIdentifier = .invalid
    }
}
