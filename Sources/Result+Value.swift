//
//  Result+Value.swift
//  
//
//  Created by Horatiu Copaciu on 18.02.2022.
//

import Foundation

public extension Result {
    var value: Success? {
        switch self {
            case .success(let value):
                return value
            case .failure:
                return nil
        }
    }
    
    var error: Error? {
        switch self {
            case .success:
                return nil
            case .failure(let error):
                return error
        }
    }
}
