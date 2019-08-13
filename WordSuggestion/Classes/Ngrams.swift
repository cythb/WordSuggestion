//
//  Ngrams.swift
//  WordSuggestion
//
//  Created by Cirno MainasuK on 2019-8-12.
//

import Foundation
import RealmSwift

public protocol NGramProtocol {
    var freq: Double { get }
    var x: String { get }
}

@objcMembers public class NGram1: Object, NGramProtocol {
    @objc public dynamic var id = 0
    @objc public dynamic var freq: Double = 0
    @objc public dynamic var x: String = ""

    override public static func primaryKey() -> String? {
        return "id"
    }
}

public class NGram2: Object, NGramProtocol {
    @objc public dynamic var id = 0
    @objc public dynamic var freq: Double = 0
    @objc public dynamic var x: String = ""
    @objc public dynamic var y: String = ""

    override public static func primaryKey() -> String? {
        return "id"
    }
}

public class NGram3: Object, NGramProtocol {
    @objc public dynamic var id = 0
    @objc public dynamic var freq: Double = 0
    @objc public dynamic var x: String = ""
    @objc public dynamic var y: String = ""

    override public static func primaryKey() -> String? {
        return "id"
    }
}

public class NGram4: Object, NGramProtocol {
    @objc public dynamic var id = 0
    @objc public dynamic var freq: Double = 0
    @objc public dynamic var x: String = ""
    @objc public dynamic var y: String = ""

    override public static func primaryKey() -> String? {
        return "id"
    }
}
