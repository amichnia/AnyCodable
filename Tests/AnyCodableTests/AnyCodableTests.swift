import XCTest
@testable import AnyCodable

class AnyCodableTests: XCTestCase {
    func testJSONDecoding() {
        let json = """
        {
            "boolean": true,
            "integer": 1,
            "double": 3.14159265358979323846,
            "string": "string",
            "array": [1, 2, 3],
            "nested": {
                "a": "alpha",
                "b": "bravo",
                "c": "charlie"
            }
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let dictionary = try! decoder.decode([String: AnyCodable].self, from: json)
        
        XCTAssertEqual(dictionary["boolean"]?.value as! Bool, true)
        XCTAssertEqual(dictionary["integer"]?.value as! Int, 1)
        XCTAssertEqual(dictionary["double"]?.value as! Double, 3.14159265358979323846, accuracy: 0.001)
        XCTAssertEqual(dictionary["string"]?.value as! String, "string")
        XCTAssertEqual(dictionary["array"]?.value as! [Int], [1, 2, 3])
        XCTAssertEqual(dictionary["nested"]?.value as! [String: String], ["a": "alpha", "b": "bravo", "c": "charlie"])
    }
    
    func testJSONEncoding() {
        let dictionary: [String: AnyCodable] = [
            "boolean": true,
            "integer": 1,
            "double": 3.14159265358979323846,
            "string": "string",
            "array": [1, 2, 3],
            "nested": [
                "a": "alpha",
                "b": "bravo",
                "c": "charlie"
            ]
        ]
        
        let encoder = JSONEncoder()
        
        let json = try! encoder.encode(dictionary)
        let encodedJSONObject = try! JSONSerialization.jsonObject(with: json, options: []) as! NSDictionary
        
        let expected = """
        {
            "boolean": true,
            "integer": 1,
            "double": 3.14159265358979323846,
            "string": "string",
            "array": [1, 2, 3],
            "nested": {
                "a": "alpha",
                "b": "bravo",
                "c": "charlie"
            }
        }
        """.data(using: .utf8)!
        let expectedJSONObject = try! JSONSerialization.jsonObject(with: expected, options: []) as! NSDictionary
        
        XCTAssertEqual(encodedJSONObject, expectedJSONObject)
    }

    func testDynamicLookupGetters() {
        let dictionary: AnyCodable = AnyCodable( [
            "boolean": true,
            "integer": 1,
            "double": 3.14159265358979323846,
            "string": "string",
            "array": [1, 2, 3],
            "nested": [
                "a": "alpha",
                "b": "bravo",
                "c": "charlie",
                "array": [
                    1,
                    2,
                    [
                        "a": "alpha",
                        "b": "bravo",
                        "c": "deep charlie"
                    ]
                ],
            ]
        ])

        XCTAssertEqual(dictionary.nested?.a, "alpha")
        XCTAssertEqual(dictionary.nested?.array?[2]?.c, "deep charlie")
    }

    func testDynamicLookupSetters() {
        var dictionary: AnyCodable = AnyCodable( [
            "boolean": true,
            "integer": 1,
            "double": 3.14159265358979323846,
            "string": "string",
            "array": [1, 2, 3],
            "nested": [
                "a": "alpha",
                "b": "bravo",
                "c": "charlie",
                "array": [
                    1,
                    2,
                    [
                        "a": "alpha",
                        "b": "bravo",
                        "c": "deep charlie"
                    ]
                ],
            ]
        ])

        // Initial verify structure
        XCTAssertEqual(dictionary.nested?.a, "alpha")
        XCTAssertEqual(dictionary.nested?.array?[2]?.c, "deep charlie")

        // Update json structure
        dictionary.nested?.array?[2]?.c = "not charlie"
        XCTAssertEqual(dictionary.nested?.array?[2]?.c, "not charlie")

        // Set nil to remove keys
        dictionary.nested?.array?[2]?.c = nil
        XCTAssertNil(dictionary.nested?.array?[2]?.c)

        // Set custom structures
        dictionary.nested?.array?[2]?.c = AnyCodable(["k1": 1, "2": 2])
        XCTAssertEqual(dictionary.nested?.array?[2]?.c?.k1, 1)
        XCTAssertEqual(dictionary.nested?.array?[2]?.c?.2, 2)

        // Aletrnative array index accessors
        XCTAssertEqual(dictionary.nested?.array?.2?.c?.k1, 1)
        XCTAssertEqual(dictionary.nested?.array?.2?.c?.2, 2)
        XCTAssertEqual(dictionary.nested?.array?.2?.c?.3, nil)
        XCTAssertEqual(dictionary.nested?.array?.3?.c?.3, nil)
    }

    static var allTests = [
        ("testJSONDecoding", testJSONDecoding),
        ("testJSONEncoding", testJSONEncoding),
        ("testDynamicLookupGetters", testJSONEncoding),
        ("testDynamicLookupSetters", testJSONEncoding),
    ]
}
