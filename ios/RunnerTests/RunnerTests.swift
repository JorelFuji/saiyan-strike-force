import Flutter
import UIKit
import XCTest

class RunnerTests: XCTestCase {

  func testDirectoryCanBeExcludedFromBackup() throws {
    let directory = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString, isDirectory: true)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }

    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    var protectedDirectory = directory
    try protectedDirectory.setResourceValues(values)

    let result = try directory.resourceValues(forKeys: [.isExcludedFromBackupKey])
    XCTAssertEqual(result.isExcludedFromBackup, true)
  }

}
