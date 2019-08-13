//
//  Ngram.swift
//  WordSuggestion
//
//  Created by Cirno MainasuK on 2019-8-12.
//

import Foundation

public class NGram: NSObject {

    public var freq: Double
    public var y: String

    public init(ngram: NGram1) {
        self.y = ngram.x
        self.freq = ngram.freq
    }

    public init(ngram: NGram2) {
        self.y = ngram.y
        self.freq = ngram.freq
    }

    public init(ngram: NGram3) {
        self.y = ngram.y
        self.freq = ngram.freq
    }

    public init(ngram: NGram4) {
        self.y = ngram.y
        self.freq = ngram.freq
    }

}
