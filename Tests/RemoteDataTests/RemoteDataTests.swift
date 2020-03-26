import XCTest
@testable import RemoteData

final class RemoteDataTests: XCTestCase {
    enum Error: Swift.Error {
        case any
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

        switch RemoteData.notAsked.map(mapper) {
        case .notAsked:
            XCTAssertEqual(true, true)
        default:
            XCTAssertEqual(false, true)
        }

        switch RemoteData.loading.map(mapper) {
        case .loading:
            XCTAssertEqual(true, true)
        default:
            XCTAssertEqual(false, true)
        }

        switch RemoteData.success("").map(mapper) {
        case let .success(val):
            XCTAssertEqual(val, 123)
        default:
            XCTAssertEqual(false, true)
        }

        switch RemoteData.failure(Error.any).map(mapper) {
        case let .failure(e):
            if let e = e as? Error, case .any = e {
                XCTAssertEqual(true, true)
            }
            else {
                XCTAssertEqual(false, true)
            }
        default:
            XCTAssertEqual(false, true)
        }
    }

    static var allTests = [
        ("testIsNotAsked", testIsNotAsked),
        ("testIsLoading", testIsLoading),
        ("testIsSuccess", testIsSuccess),
        ("testIsFailure", testIsFailure),
        ("testToOption", testToOption),
        ("testMap", testMap),
    ]
}
