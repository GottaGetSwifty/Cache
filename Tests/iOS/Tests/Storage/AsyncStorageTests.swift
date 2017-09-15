import XCTest
@testable import Cache

final class AsyncStorageTests: XCTestCase {
  private var storage: AsyncStorage!
  let user = User(firstName: "John", lastName: "Snow")

  override func setUp() {
    super.setUp()
    let memory = MemoryStorage(config: MemoryConfig())
    let disk = try! DiskStorage(config: DiskConfig(name: "Floppy"))
    let hybrid = HybridStorage(memoryStorage: memory, diskStorage: disk)
    let primitive = TypeWrapperStorage(storage: hybrid)
    storage = AsyncStorage(storage: primitive)
  }

  override func tearDown() {
    storage.removeAll(completion: { _ in })
    super.tearDown()
  }

  func testSetObject() throws {
    let expectation = self.expectation(description: #function)

    storage.setObject(user, forKey: "user", completion: { _ in })
    storage.object(forKey: "user", completion: { (result: Result<User>) in
      switch result {
      case .value(let cachedUser):
        XCTAssertEqual(cachedUser, self.user)
        expectation.fulfill()
      default:
        XCTFail()
      }
    })

    wait(for: [expectation], timeout: 1)
  }

  func testRemoveAll() {
    let expectation = self.expectation(description: #function)
    given("add a lot of objects") {
      Array(0..<100).forEach {
        storage.setObject($0, forKey: "key-\($0)", completion: { _ in })
      }
    }

    when("remove all") {
      storage.removeAll(completion: { _ in })
    }

    then("all are removed") {
      storage.existsObject(ofType: Int.self, forKey: "key-99", completion: { result in
        switch result {
        case .value:
          XCTFail()
        default:
          expectation.fulfill()
        }
      })
    }

    wait(for: [expectation], timeout: 1)
  }

  func testManyOperations() {
    var number = 0
    let iterationCount = 10_000

    when("performs lots of operations") {
      DispatchQueue.concurrentPerform(iterations: iterationCount) { _ in
        number += 1
        storage.setObject(number, forKey: "number", completion: { _ in })
      }
    }

    then("all operation must complete") {
      storage.object(forKey: "number", completion: { (result: Result<Int>) in
        switch result {
        case .value(let cachedNumber):
          XCTAssertEqual(cachedNumber, iterationCount)
        default:
          XCTFail()
        }
      })
    }
  }
}
