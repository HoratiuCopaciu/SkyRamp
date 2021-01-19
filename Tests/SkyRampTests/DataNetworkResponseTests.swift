//
//  DataNetworkResponseTests.swift
//  
//
//  Created by Horatiu Copaciu on 19/01/2021.
//

import XCTest
import SkyRamp


class DataNetworkResponseTests: NetworkResponseTests<Data> {
    
    func testJSONDecode() {
        let data = try! JSONEncoder().encode(Person(name: "John", surname: "Smith"))
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String : String]
        sut = .success(data)
        let result: [String: String] = try! sut.getJSON()
        XCTAssertEqual(json, result, "Decoded JSON does not match input")
    }
    
    func testDecodingSinglePerson() {
        let encodedPerson = Person(name: "John", surname: "Smith")
        let data = try! JSONEncoder().encode(encodedPerson)
        sut = .success(data)
        let decodedPerson: Person = try! sut.decodeJSON()
        XCTAssertEqual(encodedPerson, decodedPerson, "Decoded Person does not match encoding")
    }
    
    func testDecodingListOfPersons() {
        let encodedPersons = [Person(name: "John", surname: "Smith"), Person(name: "Sarah", surname: "Smith")]
        let data = try! JSONEncoder().encode(encodedPersons)
        sut = .success(data)
        let decodedPersons: [Person] = try! sut.decodeJSON()
        XCTAssertEqual(encodedPersons, decodedPersons, "Decoded Persons does not match encoding")
    }
}

private struct Person: Codable, Equatable {
    let name: String
    let surname: String
    
    enum CodingKeys: CodingKey {
        case name, surname
    }
}
