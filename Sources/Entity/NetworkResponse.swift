//
//  NetworkResponse.swift
//  Network
//
//  Created by Horatiu Copaciu on 03/09/2019.
//  Copyright © 2019 Horatiu Copaciu. All rights reserved.
//

import Foundation

public typealias NetworkResponse<T> = Result<T, NetworkError>

public extension NetworkResponse {
    var isSuccessful: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}

public extension NetworkResponse where Success == Void {
    static var success: Result {
        return .success(())
    }
}

public extension NetworkResponse where Success == Data {
    
    func getJSON<Value>() throws -> Value {
        do {
            let value = try self.get()
            guard let json: Value = try? JSONSerialization.jsonObject(with: value, options: []) as? Value else {
                throw NetworkError.invalidJson
            }
            return json
        } catch {
            throw NetworkError.invalidResponse
        }
    }
    
    func decodeJSON<D: Decodable>() throws -> D {
        let data = try get()
        let value = try JSONDecoder().decode(D.self, from: data)
        return value
    }
    
    func mapJSON<D: Decodable, Value>(_ transform: @escaping (D) -> Value) throws -> Value {
        guard let json: D = try getJSON() else {
            throw NetworkError.invalidJson
        }
        return transform(json)
    }
    
    func flatMapJSON<D: Decodable, Value>(_ transform: @escaping (D) -> Value?) throws -> Value? {
        do {
            let json: D = try getJSON()
            return transform(json)
        } catch {
            throw NetworkError.invalidJson
        }
    }
}
