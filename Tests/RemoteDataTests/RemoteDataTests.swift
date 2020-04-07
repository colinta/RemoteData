import XCTest
@testable import RemoteData

final class RemoteDataTests: XCTestCase {
    enum Error: Swift.Error, CustomDebugStringConvertible {
        case any
        case lhs
        case rhs
        case mapped

        var debugDescription: String {
            switch self {
            case .any: return ".any"
            case .lhs: return ".lhs"
            case .rhs: return ".rhs"
            case .mapped: return ".mapped"
            }
        }
    }

    struct Tuple: Equatable {
        let vals: [Int]

        static func ==(lhs: Tuple, rhs: Tuple) -> Bool {
            lhs.vals == rhs.vals
        }

        init(_ tuple: (Int, Int)) {
            vals = [tuple.0, tuple.1]
        }

        init(_ tuple: (Int, Int, Int)) {
            vals = [tuple.0, tuple.1, tuple.2]
        }

        init(_ tuple: (Int, Int, Int, Int)) {
            vals = [tuple.0, tuple.1, tuple.2, tuple.3]
        }

        init(_ tuple: (Int, Int, Int, Int, Int)) {
            vals = [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4]
        }

        init(_ tuple: (Int, Int, Int, Int, Int, Int)) {
            vals = [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4, tuple.5]
        }

        init(_ tuple: (Int, Int, Int, Int, Int, Int, Int)) {
            vals = [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4, tuple.5, tuple.6]
        }

        init(_ tuple: (Int, Int, Int, Int, Int, Int, Int, Int)) {
            vals = [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4, tuple.5, tuple.6, tuple.7]
        }

        init(_ tuple: (Int, Int, Int, Int, Int, Int, Int, Int, Int)) {
            vals = [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4, tuple.5, tuple.6, tuple.7, tuple.8]
        }

        init(_ tuple: (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)) {
            vals = [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4, tuple.5, tuple.6, tuple.7, tuple.8, tuple.9]
        }
    }

    func testIsNotAsked() {
        XCTAssertEqual(RemoteData<String>.notAsked.isNotAsked, true)
        XCTAssertEqual(RemoteData<String>.loading.isNotAsked, false)
        XCTAssertEqual(RemoteData.success("").isNotAsked, false)
        XCTAssertEqual(RemoteData<String>.failure(Error.any).isNotAsked, false)
    }

    func testIsLoading() {
        XCTAssertEqual(RemoteData<String>.notAsked.isLoading, false)
        XCTAssertEqual(RemoteData<String>.loading.isLoading, true)
        XCTAssertEqual(RemoteData.success("").isLoading, false)
        XCTAssertEqual(RemoteData<String>.failure(Error.any).isLoading, false)
    }

    func testIsSuccess() {
        XCTAssertEqual(RemoteData<String>.notAsked.isSuccess, false)
        XCTAssertEqual(RemoteData<String>.loading.isSuccess, false)
        XCTAssertEqual(RemoteData.success("").isSuccess, true)
        XCTAssertEqual(RemoteData<String>.failure(Error.any).isSuccess, false)
    }

    func testIsFailure() {
        XCTAssertEqual(RemoteData<String>.notAsked.isFailure, false)
        XCTAssertEqual(RemoteData<String>.loading.isFailure, false)
        XCTAssertEqual(RemoteData.success("").isFailure, false)
        XCTAssertEqual(RemoteData<String>.failure(Error.any).isFailure, true)
    }

    func testToOption() {
        XCTAssertEqual(RemoteData<String>.notAsked.toOption, nil)
        XCTAssertEqual(RemoteData<String>.loading.toOption, nil)
        XCTAssertEqual(RemoteData.success("").toOption, .some(""))
        XCTAssertEqual(RemoteData<String>.failure(Error.any).toOption, nil)
    }

    func testMap() {
        let mapper: (String) -> Int = { _ in 123 }

        assertEqual(RemoteData.notAsked.map(mapper), .notAsked)
        assertEqual(RemoteData.loading.map(mapper), .loading)
        assertEqual(RemoteData.success("").map(mapper), .success(123))
        assertError(RemoteData.failure(Error.any).map(mapper), .any)
    }

    func testMapError() {
        let mapper: (Swift.Error) -> Error = { _ in .mapped }

        assertEqual(RemoteData<String>.notAsked.mapError(mapper), .notAsked)
        assertEqual(RemoteData<String>.loading.mapError(mapper), .loading)
        assertEqual(RemoteData.success("").mapError(mapper), .success(""))
        assertError(RemoteData<String>.failure(Error.any).mapError(mapper), .mapped)
    }

    func testAndMap() {
        let notAsked: RemoteData<String> = .notAsked
        let loading: RemoteData<String> = .loading
        let successStr: RemoteData<String> = .success("hi")
        let successInt: RemoteData<Int> = .success(123)
        let successStr2: RemoteData<String> = .success("hi2")
        let successInt2: RemoteData<Int> = .success(1232)
        let failLhs: RemoteData<String> = .failure(Error.lhs)
        let failRhs: RemoteData<String> = .failure(Error.rhs)

        assertEqual(notAsked.andMap(notAsked), .notAsked)

        assertEqual(loading.andMap(notAsked), .loading)
        assertEqual(notAsked.andMap(loading), .loading)
        assertEqual(loading.andMap(loading), .loading)
        assertEqual(loading.andMap(successStr), .loading)
        assertEqual(successStr.andMap(loading), .loading)
        assertEqual(notAsked.andMap(successStr), .notAsked)
        assertEqual(successStr.andMap(notAsked), .notAsked)

        assertError(failLhs.andMap(loading), .lhs)
        assertError(loading.andMap(failRhs), .rhs)
        assertError(failLhs.andMap(notAsked), .lhs)
        assertError(notAsked.andMap(failRhs), .rhs)
        assertError(failLhs.andMap(notAsked), .lhs)
        assertError(notAsked.andMap(failRhs), .rhs)
        assertError(failLhs.andMap(loading), .lhs)
        assertError(loading.andMap(failRhs), .rhs)

        assertError(failLhs.andMap(successStr), .lhs)
        assertError(successStr.andMap(failRhs), .rhs)
        assertError(failLhs.andMap(failRhs), .lhs)

        assertEqual(successStr.andMap(successInt), .success(("hi", 123)))
        assertEqual(successStr.andMap(successInt).andMap(successStr2).andMap(successInt2).map(untuple), .success(("hi", 123, "hi2", 1232)))
    }

    func testEquatable() {
        XCTAssert(RemoteData<String>.notAsked == RemoteData<String>.notAsked)
        XCTAssert(RemoteData<String>.notAsked != RemoteData<String>.loading)
        XCTAssert(RemoteData<String>.notAsked != RemoteData<String>.success(""))
        XCTAssert(RemoteData<String>.notAsked != RemoteData<String>.failure(Error.any))

        XCTAssert(RemoteData<String>.loading != RemoteData<String>.notAsked)
        XCTAssert(RemoteData<String>.loading == RemoteData<String>.loading)
        XCTAssert(RemoteData<String>.loading != RemoteData<String>.success(""))
        XCTAssert(RemoteData<String>.loading != RemoteData<String>.failure(Error.any))

        XCTAssert(RemoteData<String>.success("") != RemoteData<String>.notAsked)
        XCTAssert(RemoteData<String>.success("") != RemoteData<String>.loading)
        XCTAssert(RemoteData<String>.success("") == RemoteData<String>.success(""))
        XCTAssert(RemoteData<String>.success("") != RemoteData<String>.failure(Error.any))
        XCTAssert(RemoteData<String>.success("123") != RemoteData<String>.success("abc"))

        XCTAssert(RemoteData<String>.failure(Error.any) != RemoteData<String>.notAsked)
        XCTAssert(RemoteData<String>.failure(Error.any) != RemoteData<String>.loading)
        XCTAssert(RemoteData<String>.failure(Error.any) != RemoteData<String>.success(""))
        XCTAssert(RemoteData<String>.failure(Error.any) != RemoteData<String>.failure(Error.any))
    }

    func testUntuple() {
        XCTAssertEqual(Tuple(untuple((1, 2))), Tuple((1, 2)))
        XCTAssertEqual(Tuple(untuple(((1, 2), 3))), Tuple((1, 2, 3)))
        XCTAssertEqual(Tuple(untuple((((1, 2), 3), 4))), Tuple((1, 2, 3, 4)))
        XCTAssertEqual(Tuple(untuple(((((1, 2), 3), 4), 5))), Tuple((1, 2, 3, 4, 5)))
        XCTAssertEqual(Tuple(untuple((((((1, 2), 3), 4), 5), 6))), Tuple((1, 2, 3, 4, 5, 6)))
        XCTAssertEqual(Tuple(untuple(((((((1, 2), 3), 4), 5), 6), 7))), Tuple((1, 2, 3, 4, 5, 6, 7)))
        XCTAssertEqual(Tuple(untuple((((((((1, 2), 3), 4), 5), 6), 7), 8))), Tuple((1, 2, 3, 4, 5, 6, 7, 8)))
        XCTAssertEqual(Tuple(untuple(((((((((1, 2), 3), 4), 5), 6), 7), 8), 9))), Tuple((1, 2, 3, 4, 5, 6, 7, 8, 9)))
        XCTAssertEqual(Tuple(untuple((((((((((1, 2), 3), 4), 5), 6), 7), 8), 9), 10))), Tuple((1, 2, 3, 4, 5, 6, 7, 8, 9, 10)))
    }

    private func assertError<T>(_ l: RemoteData<T>, _ r: Error, file: StaticString = #file, line: UInt = #line) {
        do {
            _ = try l.get()
            XCTFail("did not throw", file: file, line: line)
        } catch {
            if let error = error as? Error, error != r {
                XCTFail("is not .lhs", file: file, line: line)
            }
            else {
            }
        }
    }

    private func assertEqual<T>(_ l: RemoteData<T>, _ r: RemoteData<T>, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual("\(l)", "\(r)", file: file, line: line)
    }

    static var allTests = [
        ("testIsNotAsked", testIsNotAsked),
        ("testIsLoading", testIsLoading),
        ("testIsSuccess", testIsSuccess),
        ("testIsFailure", testIsFailure),
        ("testToOption", testToOption),
        ("testMap", testMap),
        ("testMapError", testMapError),
        ("testAndMap", testAndMap),
        ("testEquatable", testEquatable),
        ("testUntuple", testUntuple),
    ]
}
