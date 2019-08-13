//
//  WordSuggestionTests.swift
//  WordSuggestion_Tests
//
//  Created by Cirno MainasuK on 2019-8-12.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import WordSuggestion
import RealmSwift

class WordSuggestionTests: XCTestCase {

    var realm: Realm!

    override func setUp() {
        var config = Realm.Configuration()
        let realmName = "WordPredictor_default"
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(realmName).realm")
        config.objectTypes = [NGram1.self, NGram2.self, NGram3.self, NGram4.self]
        try? FileManager.default.createDirectory(at: config.fileURL!.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        realm = try! Realm(configuration: config)
        print(config.fileURL!)
    }

    func testCleanUp() {
        realm.beginWrite()
        realm.deleteAll()
        try! realm.commitWrite()
    }

    func testLoadNgram() {
        let path = WordPredictor.NgramPath.default
        XCTAssertNotNil(path)

        let wordPredictor = WordPredictor(ngramPath: path!, realm: realm)
        let loadExpectation = expectation(description: "load")
        wordPredictor.load { error in
            XCTAssertNil(error)
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 200)

        // profile: CPU: peak 300% Time: ~10s RAM: peak 200M
    }

}
